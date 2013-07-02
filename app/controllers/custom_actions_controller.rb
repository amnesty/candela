class CustomActionsController < ApplicationController
  
  include ActionController::AIController

  
  authorization_filter :create, :custom_action, :only => [ :new, :create ]
  authorization_filter :read,   :custom_action, :only => [ :show, :index ]
  authorization_filter :update, :custom_action, :only => [ :edit, :update]
  authorization_filter :destroy, :custom_action, :only => [ :delete, :destroy ]
  
  before_filter :set_organization_type,         :only => [ :create ]
  before_filter :set_organization_by_container, :only => [ :new, :create ]
  
  def index
    if current_container
      super(:query_to => current_container.custom_actions)
    else
      @custom_actions = CustomAction.can_see(current_agent).include_in(:organization).all
      @custom_actions.sort! { |a,b| a.organization.name.to_s.parameterize.to_s <=> b.organization.name.to_s.parameterize.to_s }
      render :template => 'custom_actions/index_by_organizations'            
    end
  end

  
  private
  def set_organization_type
    if params[:custom_action] and params[:custom_action][:organization_type]
      if params[:custom_action][:organization_type].empty?
        flash[:error] = Gx.t_error("custom_action.organization_type.empty")
      else
        @custom_action.organization_type = params[:custom_action][:organization_type]
      end
    end
      
    if params[:custom_action] and params[:custom_action][:organization_type] and params[:custom_action][:organization_id]
      @custom_action.organization = params[:custom_action][:organization_type].constantize.find(params[:custom_action][:organization_id]) if @custom_action.organization.nil?
    end                                                     
  end
  
  def set_organization_by_container
    @custom_action.organization = current_container if current_container
  end
end
