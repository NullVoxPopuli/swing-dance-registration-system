module CollaborationOperations
  module Helpers
    def collaboration
      return @collaboration if @collaboration

      # just something to keep track of errors for the UI
      @collaboration = Collaboration.new
      @collaboration.errors.add(:base, 'event or organization not found') unless host
      @collaboration.collaborated = host
      @collaboration
    end

    def host
      @host ||= find_host
    end

    def find_host
      kind = params_for_action[:host_type]
      if [Event.name, Organization.name].include?(kind)
        klass = kind.safe_constantize
        klass.find(params_for_action[:host_id]) if klass
      end
    end
  end
end