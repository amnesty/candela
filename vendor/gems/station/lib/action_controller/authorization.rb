module ActionController #:nodoc:
  # Authorization module provides your Controllers and Views with methods and filters
  # to control the actions of Agents
  #
  # This module uses Agent identification support from ActionController::Authentication
  #
  # == Authorization Filters
  # You can define authorization filters in the following way:
  #   authorization_filter permission, object, filter_options
  #
  # permission:: Argument defining the Permission, ex. :read, [ :update, :task ]
  # object:: a Symbol representing a controller's instance variable name or method. This variable or method gives the object which will be called <tt>authorize?(permission, :to => current_agent)</tt>
  # options:: Available options are:
  #   if:: A Proc proc{ |controller| ... } or Symbol to be executed as condition of the filter
  #
  #  The rest of options are passed to before_filter. See Rails before_filter documentation
  #
  #
  # === Examples
  #
  #  class AttachmentsController < ActionController::Base
  #    authorization_filter [ :read, :attachment ], :space, { :only => [ :index ] }
  #    authorization_filter [ :create, :attachment ], :space, { :only => [ :new, :create ] }
  #
  #    authorization_filter :read, :attachment, :only => [ :show ]
  #    authorization_filter :update, :attachment, :only => [ :edit, :update ]
  #    authorization_filter :destroy, :attachment, :only => [ :destroy ]
  #
  #  end
  #
  module Authorization
    # Inclusion hook to add ActionController::Authentication
    def self.included(base) #:nodoc:
      base.send :include, ActionController::Authentication unless base.ancestors.include?(ActionController::Authentication)

      base.helper_method :authorize?, :authorized?
      # Deprecated
      base.helper_method :authorizes?

      class << base
        # Calls not_authorized unless stage allows current_agent to perform actions
        def authorization_filter(permission, auth_object, options = {})
          if_condition = options.delete(:if)
          filter_condition = case if_condition
                             when Proc
                               if_condition
                             when Symbol
                               proc{ |controller| controller.send(if_condition) }
                             else
                               proc{ |controller| true }
                             end

          before_filter options do |controller|

            if filter_condition.call(controller)
              controller.not_authorized unless controller.authorized?(permission, auth_object)
            end
          end
        end
      end
    end

    # Object that resolves default authorization queries. Defaults to current_site
    def default_authorization_instance
      current_site
    end

    # Calls authorize? on default_authorization_instance with current_agent
    #
    # permission defaults to controller's action_name
    def authorize?(permission = nil)
      permission ||= action_name

      default_authorization_instance.authorize?(permission, :to => current_agent)
    end

    # If user is not authenticated, return not_authenticated to allow identification.
    # Else, set HTTP Forbidden (403) response.
    def not_authorized
      return not_authenticated unless authenticated?

      render(:file => "#{Rails.root}/public/403.html",
             :status => 403)
    end

    def authorized?(permission = nil, auth_object_name = nil) #:nodoc:
      permission ||= action_name.to_sym
      auth_object = case auth_object_name
                   when Symbol
                     begin
                      self.instance_variable_get("@#{ auth_object_name }")
                     rescue NameError
                     end || send(auth_object_name)
                   when NilClass
                     default_authorization_instance
                   else
                     auth_object_name
                   end

      auth_object.authorize?(permission, :to => current_agent)
    end
  end
end
