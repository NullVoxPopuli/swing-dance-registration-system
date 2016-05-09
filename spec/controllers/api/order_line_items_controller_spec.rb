require 'rails_helper'

describe Api::OrderLineItemsController, type: :controller do
  describe 'create' do
    before(:each) do
      @organization = create(:organization)
      @user = create(:user)
      @membership_option = create(:membership_option, host: @organization)
      login_through_api(@user)
      @order = create(:order, user: @user, host: @organization)
    end

    it 'creates a new order line item' do
      json_api = {
        data: {
          type: 'order-line-items',
          attributes: {
            price: '10.0',
            quantity: 2,
            partner_name: 'me',
            dance_orientation: 'lead',
            size: 's'
          },
          relationships: {
            order: {
              data: {
                id: @order.id,
                type: 'orders'
              }
            },
            line_item: {
              data: {
                id: @membership_option.id,
                type: 'line-item'
              }
            }
          }
        }
      }

      json_api_create_with(OrderLineItem, json_api)
    end
  end

  describe 'update' do
    before(:each) do
      @organization = create(:organization)
      @user = create(:user)
      @membership_option = create(:membership_option, host: @organization)
      login_through_api(@user)
      @order = create(:order, user: @user, host: @organization)
      @oli = create(:order_line_item, order: @order, line_item: @membership_option)
    end

    it 'creates a new order line item' do
      json_api = {
        data: {
          id: @oli.id,
          type: 'order-line-items',
          attributes: {
            price: '17.0',
            quantity: 2,
            partner_name: 'me',
            dance_orientation: 'lead',
            size: 's'
          }
        }
      }

      json_api_update_with(@oli, json_api)
    end
  end

end
