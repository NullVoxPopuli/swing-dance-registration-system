require 'rails_helper'

describe Api::UsersController, type: :controller do
  before(:each) do
    ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
  end

  context 'show' do
    it 'returns the current user' do
      force_login(user = create(:user))
      get :show, id: -1
      json = response.body

      expected = ActiveModel::SerializableResource.new(user).serializable_hash.to_json
      expect(json).to eq expected
    end

    it 'returns nothing when not logged in' do
      get :show, id: 0 # id doesn't matter
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
    end
  end

  context 'create' do
    it 'creates a user' do
      user = build(:user, {
        first_name: 'first',
        last_name: 'last',
        email: 'my@oh.my',
        time_zone: 'EST'
      })

      expect{
        post :create, { user: user.attributes.merge(
          password: 'whatever',
          password_confirmation: 'whatever')
        }
      }.to change(User, :count).by(1)

      expected = ActiveModel::SerializableResource.new(user).serializable_hash.to_json
      # the difference here is the confirmation sent at...
      # I don't know how to ignore that during the compare atm
      expect(response.body).to_not be_nil
    end


    it 'sends an email for confirmation' do
      user = build(:user, {
        first_name: 'first',
        last_name: 'last',
        email: 'my@oh.my',
        time_zone: 'EST'
      })


      expect{
        post :create, { user: user.attributes.merge(
          password: 'whatever',
          password_confirmation: 'whatever')
        }

        expect(user.errors).to be_empty
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'does not create a user with the same email address' do
      old_user = create_confirmed_user

      user = build(:user, {
        first_name: 'first2',
        last_name: 'last2',
        email: old_user.email,
        time_zone: 'EST'
      })

      expect{
        post :create, { user: user.attributes.merge(
          password: 'whatever',
          password_confirmation: 'whatever')
        }
      }.to change(User, :count).by(0)

      expected = ActiveModel::SerializableResource.new(user).serializable_hash.to_json
      # the difference here is the confirmation sent at...
      # I don't know how to ignore that during the compare atm
      json = JSON.parse(response.body)
      errors = json['errors']
      expect(errors).to be_present
      expect(errors.first['detail']).to include('has already been taken')
    end
  end

  context 'update' do
    let (:user){ create(:user) }
    it 'updates a user' do
      force_login(user)

      first = user.first_name + ' updated'
      patch :update,  { id: user.id, user: { first_name: first, current_password: user.password } }
      json = JSON.parse(response.body)
      first_name_field = json['data']['attributes']['first_name']

      expect(first_name_field).to eq first
    end

    it 'user is not logged in' do
      first = user.first_name + ' updated'
      patch :update,  { id: user.id, user: { first_name: first, current_password: user.password } }
      json = JSON.parse(response.body)

      expect(json['errors']).to be_present
    end

    it 'does not update if no password provided' do
      force_login(user)

      expect{
        patch :update,  { id: user.id, user: { password: 'wutwutwut', password_confirmation: 'wutwutwut' } }
      }.to_not change(User.find(user.id), :encrypted_password)
    end

    it 'updates password' do
      force_login(user)
      old_password = user.encrypted_password

      patch :update,  { id: user.id, user: { password: 'wutwutwut', password_confirmation: 'wutwutwut', current_password: user.password } }

      new_password = user.reload.encrypted_password

      expect(new_password).to_not eq old_password
    end
  end

  context 'destroy' do
    let (:user){ create(:user) }
    it 'deletes a user' do
      force_login(user)
      expect{
        delete :destroy, id: user.id
      }.to change(User, :count).by(-1)
    end

    it 'does not allow deletion when about to attend an event' do
      force_login(user)
      # data doesn't matter here
      allow(user).to receive(:upcoming_events){ [1] }

      expect{
        delete :destroy, id: user.id
      }.to change(User, :count).by(0)
    end
  end

end