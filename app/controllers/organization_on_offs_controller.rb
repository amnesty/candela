class OrganizationOnOffsController < ApplicationController
  include ActionController::AIController
  
  before_filter :container_to_object

  authorization_filter :create, :organization_on_off, :only => [ :new, :create ]
  authorization_filter :read,   :organization_on_off, :only => [ :show, :index ]
  authorization_filter :update, :organization_on_off, :only => [ :edit, :update]
  authorization_filter :destroy, :organization_on_off, :only => [ :delete, :destroy ]

  # TODO Destroy last
  private
  def container_to_object
    if @organization_on_off
      @organization_on_off.container = current_container
    else
      params[:organization_on_off].delete("#{ current_container.class.name.underscore }_id") if params[:organization_on_off]
      @organization_on_off     = current_container.organization_on_offs.new(params[:organization_on_off])
      @organization_on_off.organization_type = params[:organization_on_off][:organization_type] if params[:organization_on_off] and params[:organization_on_off][:organization_type]
      @resource = @organization_on_off
    end
  end
end

