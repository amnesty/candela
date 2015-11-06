module ActionController

  module AIOrganizationController

    class << self
      def included(base) #:nodoc:
        base.send :include, ActionController::AIController
      end
    end

    # Definitions for filters on index action
    def filters_for_index
      {
        :enabled => [:filter_enabled, true],
      }
    end

    # Default values for filters on index action
    def default_filters_for_index
      {
        :enabled => true,
      }
    end
    
  end
end
