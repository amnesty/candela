module ActiveRecord #:nodoc:
  # Agents are models that can perform actions in the application. The paradigm of Agents are Users.
  #
  # == Authorization
  # Agents perform a Role in each Stage they participate. This Role defines the permissions the Agent can 
  # perform in the Stage. See ActionController::Authorization to define filters in your application.
  #
  # Include Agent functionality in your models using ActsAsMethods#acts_as_agent
  module Agent
    class << self
      
      # All Agent instances, sort by name
      def all
        classes.map(&:all).flatten.uniq.sort{ |x, y| x.name <=> y.name }
      end

      def included(base) #:nodoc:
        base.extend ActsAsMethods
      end
    end

    module ActsAsMethods
      # Provides an ActiveRecord model with Agent capabilities
      def acts_as_agent(options={})
        ActiveRecord::Agent.register_class(self)

        has_many :agent_performances, 
                 :class_name => "Performance", 
                 :dependent => :destroy,
                 :as => :agent


        extend  ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # All Stages in which this Agent has a Performance
      #
      # Can pass options to the list:
      # type:: the class of the Stage requested (Doesn't work with STI!)
      #
      # Uses +compact+ to remove nil instances, which may appear because of default_scopes
      def stages(options = {})
        agent_performances.stage_type(options[:type]).all(:include => :stage).map(&:stage).compact
      end

      # Agents that have at least one Role in stages
      def fellows
        stages.map(&:actors).flatten.compact.uniq.sort{ |x, y| x.name <=> y.name }
      end

    end
  end
end
