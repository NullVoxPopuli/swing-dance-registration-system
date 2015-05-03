module LegacyPayable
  extend ActiveSupport::Concern

  def legacy_total
    result = legacy_line_items_total

    # apply discounts
    discounts.each{ |d|
      if d[:kind].to_i == Discount::DOLLARS_OFF
        result -= d[:amount].to_f
        result = 0 if result < 0
      elsif d[:kind].to_i == Discount::PERCENT_OFF
        result *= (1 - d[:amount].to_f / 100.0)
      end

    }

    return result.round(2)
  end


  # should include packages, competitions, and a la carte / line items
  def legacy_line_items_total
    result = 0
    if legacy_line_items.present?
      result += (legacy_line_items.map{ |item| item[:price].to_f * ( item[:quantity].to_i || 1 ) }).inject(:+)
    end
    return result.round(2)
  end


  # @param [String] type name of object for how to apply discounts
  def add_custom_item(price: 0, quantity: 0, name: "", type: "")
    items = legacy_line_items
    items << {
      price: price,
      quantity: quantity,
      name: name,
      type: type
    }
    self.legacy_line_items = items
  end


  # @param [Fixnum] dollar or percent off
  # @param [Fixnum] kind Discount::DOLLARS_OFF or Discount::PERCENT_OFF
  # @param [Fixnum] to what the discount applies to
  def add_discount(amount: 0, kind: Discount::DOLLARS_OFF, to: "")
    active_discounts = discounts
    active_discounts << {
      amount: amount,
      kind: kind,
      to: to
    }
    self.discounts = active_discounts
  end

  def legacy_line_items
    l = (self.metadata["line_items"] || [])
    l.map{|h| h.default_proc = proc do |h, k|
        case k
        when String then sym = k.to_sym; h[sym] if h.key?(sym)
        when Symbol then str = k.to_s; h[str] if h.key?(str)
        end
      end
    }
    l
  end

  def legacy_line_items=(items)
    self.metadata["line_items"] = items
  end

  def discounts
    d = (self.metadata["discounts"] || [])
    d.map{|h| h.default_proc = proc do |h, k|
        case k
        when String then sym = k.to_sym; h[sym] if h.key?(sym)
        when Symbol then str = k.to_s; h[str] if h.key?(str)
        end
      end
    }
    d
  end

  def discounts=(discounts)
    self.metadata["discounts"] = discounts
  end

end