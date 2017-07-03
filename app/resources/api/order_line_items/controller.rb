# frozen_string_literal: true
module Api
  # Note that unless authenticated, all requests
  # to this controller must include a
  # payment_token param
  class OrderLineItemsController < Api::ResourceController

    def index
      render_models(params[:include])
    end

    def create
      render_model('order.order_line_items.line_item,line_item.restraints', success_status: 201)
    end

    def update
      render_model('line_item,order.order_line_items')
    end

    def destroy
      render_model('order.order_line_items')
    end

    def mark_as_picked_up
      render_model
    end

    private

    def create_order_line_item_params
      whitelistable_params(polymorphic: [:line_item]) do |whitelister|
        whitelister.permit(
          :line_item_id, :line_item_type, :order_id,
          :price, :quantity,
          :partner_name, :dance_orientation, :size,
          :discount_code
        )
      end
    end

    def update_order_line_item_params
      whitelistable_params(polymorphic: [:line_item]) do |whitelister|
        whitelister.permit(
          :line_item_id, :line_item_type,
          :price, :quantity,
          :partner_name, :dance_orientation, :size
        )
      end
    end

  end
end
