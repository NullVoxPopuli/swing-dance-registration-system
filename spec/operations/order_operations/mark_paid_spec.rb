require 'spec_helper'

describe OrderOperations::MarkPaid do
  let(:klass){ OrderOperations::MarkPaid }
  let(:owner){ create_confirmed_user }
  let(:event){ create(:event, hosted_by: owner) }
  let(:attendance){ create(:attendance, host: event) }

  context 'order is paid' do
    it 'does not change any of the attributes' do
      order = create(:order,
        host: event,
        attendance: attendance,
        payment_method: "Boop")

      params = {
        id: order.id,
        payment_method: 'Cash'
      }

      result = klass.new(owner, params).run
      expect(result.payment_method).to eq 'Cash'
    end
  end

  context 'order is unpaid' do
    it 'marks an order as paid' do
      order = create(:order, host: event, attendance: attendance)

      params = {
        id: order.id,
        payment_method: 'Cash'
      }

      result = klass.new(owner, params).run
      expect(result.paid).to eq true
    end

    it 'marks an order as paid with persistence' do
      order = create(:order, host: event, attendance: attendance)

      params = {
        id: order.id,
        payment_method: 'Cash'
      }

      result = klass.new(owner, params).run
      result.reload
      expect(result.paid).to eq true
    end
  end
end
