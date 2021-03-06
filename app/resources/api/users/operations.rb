# frozen_string_literal: true

module UserOperations
  class Update < SkinnyControllers::Operation::Base
    def run
      return unless allowed_for?(current_user)
      current_user.update_with_password(model_params)
      current_user
    end
  end

  class Delete < SkinnyControllers::Operation::Base
    def run
      return unless allowed_for?(current_user)

      # TODO: maybe provide a link to the registered events
      # so that they can cancel if they *really* want to cancel their account.
      # alternatively, just change the wording to 'deactivate', and change the
      # relationship to the user to include deleted_at
      if current_user.upcoming_events.count.positive?
        current_user.errors.add(
          :base,
          'You cannot delete your account when you are about to attend an event. You will first have to cancel all your registrations'
        )
      else
        current_user.destroy
      end

      current_user
    end
  end
end
