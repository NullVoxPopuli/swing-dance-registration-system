module Payable
  module Methods
    PAYPAL = "PayPal"
    CHECK = "Check"
    CREDIT = "Credit"
    DEBIT = "Debit"
    CASH = "Cash"
    STRIPE = "Stripe"

    ALL = [
      PAYPAL,
      STRIPE,
      CHECK,
      CREDIT,
      DEBIT,
      CASH
    ]

    FEES = {
      STRIPE => Proc.new{ |amount|
        # 30 cents + 2.9%
        0.30 + (amount * 0.029)
        # $100 + (($100.3 / 0.975) * 0.25) + 0.3
        # amount + ((amount / 1 - 0.029) - 0.3) * 1.029 + 0.3
      },
      PAYPAL => Proc.new{ |amount|
        # 30 cents + 2.9%
        0.30 + (amount * 0.029)
        # (amount + ((amount / (1 - 0.029)) - 0.3) * 0.029 + 0.3).round(2)
      }
    }

  end

  FEES = Payable::Methods::FEES

  extend ActiveSupport::Concern

  # original implementation
  # - didn't have references to line items
  include LegacyPayable

  # metadata item lists should be an array of hashes
  # [
  #   {name: "Dance", quantity: 3, price: 5},
  #   {name: "Shirt", quantity: 1, price: 7}
  # ]

  def fee
    self.total * 0.0075 # 0.75%
  end

  def add(object, quantity: 1, price: nil)
    if object.is_a?(Discount)
      if !allows_discounts?
        return false
      end

      if already_has_discount? &&
          !allows_multiple_discounts?
        return false
      end

      # check if the discount is allowed for this order
      allowed = object.allowed_packages
      if allowed.present?
        # ensure just one of the allowed packages is present
        # in this order
        package_eligibility = allowed.map do |package|
          already_exists?(package)
        end

        return false unless package_eligibility.any?
      end

    end


    if already_exists?(object)
      if [Discount, Competition, Package].include?(object.class)
        return false
      else
        # line items have quantity
        return increment_quantity_of_line_item_matching(object)
      end
    end

    price ||= (object.try(:current_price) || object.try(:value))
    item = self.line_items.new(
      quantity: quantity,
      price: price
    )

    item.line_item_id = object.id
    item.line_item_type = object.class.name
    item.save
    item
  end

  def allows_discounts?
    host.allow_discounts?
  end

  def allows_multiple_discounts?
    host.allow_combined_discounts?
  end

  def already_has_discount?
    self.line_items.select{|line_item|
      line_item.line_item_type == Discount.name
    }.count > 0
  end

  def increment_quantity_of_line_item_matching(object)
    # find existing line item with same id and type
    line_item = line_item_matching(object)
    # increment quantity and save
    line_item.quantity += 1
    line_item.save
  end

  def already_exists?(object)
    !!line_item_matching(object)
  end

  def line_item_matching(object)
    self.line_items.select{|line_item|
      line_item.line_item_id == object.id &&
      line_item.line_item_type == object.class.name
    }.first
  end

  def add_check_number(number)
    check_data = checks
    check_data << {
      number: number
    }
    self.checks = check_data
  end

  def sub_total
    return legacy_total if is_legacy?
    amount = 0
    remaining_discounts = []


    self.line_items.each do |line_item|
      if (object = line_item.line_item).is_a?(Discount)
        if object.kind == Discount::DOLLARS_OFF
          if object.class.name == Discount.name
            amount -= object.value
          else
            amount -= (object.value * line_item.quantity)
          end
        else
          # discounts will be applied after the amount is totaled
          remaining_discounts << object
        end
      else
        amount += (line_item.price * line_item.quantity)
      end

    end

    remaining_discounts.each do |discount|
      # this will be expanded later for discounts on packages
      if discount.kind == Discount::DOLLARS_OFF
        amount -= discount.value
      else discount.kind == Discount::PERCENT_OFF
        amount -= (amount * discount.value / 100.0)
      end
    end

    amount > 0 ? amount : 0
  end

  def total
    sub = sub_total
    total = sub

    # optionally make the registrant pay more
    if host.make_attendees_pay_fees? &&
        (self.payment_method == Payable::Methods::STRIPE ||
         self.payment_method == Payable::Methods::PAYPAL)
        total_fee_percentage = 0.029 # Stripe
        total_fee_percentage += 0.0075 unless host.beta?

        total = (sub + 0.3) / (1 - total_fee_percentage).round(2)
    end

    total
  end

  def net_received
    net_amount_received == 0 ? total : net_amount_received
  end

  def is_legacy?
    !!self.metadata["line_items"].present?
  end


  def checks
    c = (self.metadata["checks"] || [])
    c.map{|h| h.default_proc = proc do |h, k|
        case k
        when String then sym = k.to_sym; h[sym] if h.key?(sym)
        when Symbol then str = k.to_s; h[str] if h.key?(str)
        end
      end
    }
    c
  end

  def checks=(checks)
    self.metadata["checks"] = checks
  end

  def calculate_paid_amount
    if self.paid?
      if self.payment_method == Payable::Methods::STRIPE &&
          self.metadata["details"]
        # stripe stores money as cents
        self.metadata["details"]["amount"] / 100.0
      else
        total
      end
    else
      0
    end
  end

end