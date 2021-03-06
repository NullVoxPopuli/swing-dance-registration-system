# frozen_string_literal: true

require 'spec_helper'

describe Api::OrderLineItemPolicy do
  let(:by_owner) {
    ->(method, paid = false) {
      event = create(:event)
      order = create(:order, host: event, registration: create(:registration))
      order.paid = paid
      order_item = create(:order_line_item, order: order, line_item: create(:shirt, host: event), size: 'S')
      policy = Api::OrderLineItemPolicy.new(order_item.order.user, order_item)
      policy.send(method)
    }
  }

  let(:by_event_owner) {
    ->(method, paid = false) {
      event = create(:event)
      order = create(:order, host: event, registration: create(:registration))
      order.paid = paid
      order_item = create(:order_line_item, order: order, line_item: create(:shirt, host: event), size: 'S')
      policy = Api::OrderLineItemPolicy.new(event.hosted_by, order_item)
      policy.send(method)
    }
  }

  let(:by_a_collaborator) {
    ->(method, paid = false) {
      event = create(:event)
      order = create(:order, host: event, registration: create(:registration))
      order.paid = paid
      order_item = create(:order_line_item, order: order, line_item: create(:shirt, host: event), size: 'S')
      collaborator = create(:user)
      event.collaborators << collaborator
      event.save
      policy = Api::OrderLineItemPolicy.new(collaborator, order_item)
      policy.send(method)
    }
  }

  let(:by_a_stranger) {
    ->(method) {
      event = create(:event)
      order = create(:order, host: event, registration: create(:registration))
      order_item = create(:order_line_item, order: order, line_item: create(:shirt, host: event), size: 'S')
      policy = Api::OrderLineItemPolicy.new(create(:user), order_item)
      policy.send(method)
    }
  }

  context 'can be read?' do
    it 'by the event owner' do
      result = by_event_owner.call(:read?)
      expect(result).to eq true
    end

    it 'by order owner' do
      result = by_owner.call(:read?)
      expect(result).to eq true
    end

    it 'not by a stranger' do
      result = by_a_stranger.call(:read?)
      expect(result).to eq false
    end
  end

  context 'can be updated?' do
    it 'by the event owner' do
      result = by_event_owner.call(:update?)
      expect(result).to eq true
    end

    it 'by the event owner when order is paid' do
      result = by_event_owner.call(:update?, true)
      expect(result).to eq false
    end

    it 'by order owner' do
      result = by_owner.call(:update?)
      expect(result).to eq true
    end

    it 'by order owner when order is paid' do
      result = by_owner.call(:update?, true)
      expect(result).to eq false
    end

    it 'not by a stranger' do
      result = by_a_stranger.call(:update?)
      expect(result).to eq false
    end
  end

  context 'can be created?' do
    it 'by the event owner' do
      result = by_event_owner.call(:create?)
      expect(result).to eq true
    end

    it 'by the event owner when order is paid' do
      result = by_event_owner.call(:create?, true)
      expect(result).to eq false
    end

    it 'by order owner' do
      result = by_owner.call(:create?)
      expect(result).to eq true
    end

    it 'by order owner when order is paid' do
      result = by_owner.call(:create?, true)
      expect(result).to eq false
    end

    it 'not by a stranger' do
      result = by_a_stranger.call(:create?)
      expect(result).to eq false
    end
  end

  context 'can be destroyed?' do
    it 'by the event owner' do
      result = by_event_owner.call(:delete?)
      expect(result).to eq true
    end

    it 'by the event owner when order is paid' do
      result = by_event_owner.call(:delete?, true)
      expect(result).to eq false
    end

    it 'by order owner' do
      result = by_owner.call(:delete?)
      expect(result).to eq true
    end

    it 'by order owner when order is paid' do
      result = by_owner.call(:delete?, true)
      expect(result).to eq false
    end

    it 'not by a stranger' do
      result = by_a_stranger.call(:delete?)
      expect(result).to eq false
    end
  end

  context 'can be marked as picked up' do
    it 'by the event owner' do
      result = by_event_owner.call(:mark_as_picked_up?)
      expect(result).to eq true
    end

    it 'by a collaborator' do
      result = by_a_collaborator.call(:mark_as_picked_up?)
      expect(result).to eq true
    end

    it 'by a stranger' do
      result = by_a_stranger.call(:mark_as_picked_up?)
      expect(result).to eq false
    end
  end
end
