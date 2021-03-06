# frozen_string_literal: true

module Api
  class CustomFieldsController < Api::EventResourceController
    self.serializer = CustomFieldSerializableResource

    private

    def update_custom_field_params
      whitelistable_params do |whitelister|
        whitelister.permit(
          :label, :kind, :default_value, :editable
        )
      end
    end

    def create_custom_field_params
      whitelistable_params(polymorphic: [:host]) do |whitelister|
        whitelister.permit(
          :label, :kind, :default_value, :editable,
          :host_id, :host_type
        )
      end
    end
  end
end
