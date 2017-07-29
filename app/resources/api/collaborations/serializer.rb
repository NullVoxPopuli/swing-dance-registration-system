# frozen_string_literal: true
module Api
  class CollaborationSerializer < ActiveModel::Serializer
    attributes :id, :email,
      :user_name, :title, :created_at

    belongs_to :host

    def id
      object.id || 'invited'
    end

    def host
      object.collaborated
    end

    def user_name
      object.user&.name
    end

    def email
      object.user&.email
    end
  end
end
