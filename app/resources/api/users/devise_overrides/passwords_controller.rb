# frozen_string_literal: true

module Api
  module Users
    module DeviseOverrides
      class PasswordsController < Devise::PasswordsController
        include Controllers::ModelRendering

        respond_to :html, :json

        # prepend_before_filter :logout, only: :edit
        # skip_before_filter :require_no_authentication
        # skip_before_filter :verify_authenticity_token
        # skip_before_filter :authenticate_user_from_token
        # skip_before_filter :authenticate_user!
        # skip_before_filter :assert_reset_token_passed

        def update
          # because devise isn't meant for APIs.... :-(
          # copied from:
          # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/passwords_controller.rb
          self.resource = resource_class.reset_password_by_token(resource_params)
          yield resource if block_given?
          # mosty, I just removed a bunch of the devise code...
          respond_with resource
        end

        private

        def respond_with(obj, *_args)
          return render json: obj if obj.is_a?(Hash)

          if obj.is_a?(User)
            return render_jsonapi(
              model: obj,
              options: {
                class: '::Api::UserSerializableResource'
              }
            )
          end

          raise "Unknown password-reset render #{obj.class.name}"
        end

        def respond_with_navigational(*args)
          respond_with(*args)
        end

        def resource_name
          :user
        end
      end
    end
  end
end
