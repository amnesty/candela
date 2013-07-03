class TalksController < ApplicationController
  
  include ActionController::AIController

  authorization_filter :create,  :talk, :only => [ :new,    :create ]
  authorization_filter :read,    :talk, :only => [ :show,   :index ]
  authorization_filter :update,  :talk, :only => [ :edit,   :update ]
  authorization_filter :destroy, :talk, :only => [ :delete, :destroy ]

  skip_before_filter :authenticate_user!, :only => [:talks_as_options_for_interesteds ]

  before_filter :set_organization_type,         :only => [ :create ]
  before_filter :set_organization_by_container, :only => [ :new, :create ]
  
  def talks_as_options_for_interesteds
    @local_organization = LocalOrganization.find_by_id(params[:local_organization_id])
    @talks = []
    @local_organization.talks.order_by_nexts.each{ |talk| @talks << talk if talk.has_place? and talk.date > Date.today } if @local_organization

    render :template => 'talks/talks_as_options', :layout => nil
  end

  def talks_as_options_for_search
    @local_organization = LocalOrganization.find_by_id(params[:local_organization_id])
    if @local_organization
      @talks = @local_organization.talks.order_by_nexts.each
    end
    render :template => 'talks/talks_as_options', :layout => nil
  end

  private
  def set_organization_type
    if params[:talk][:organization_type]
      @talk.organization_type = params[:talk][:organization_type]
    end
      
    if params[:talk][:organization_type] and params[:talk][:organization_id]
      @talk.organization = params[:talk][:organization_type].constantize.find(params[:talk][:organization_id]) if @talk.organization.nil?
    end                                                     
  end
  
  def set_organization_by_container
    @talk.organization = current_container if current_container
  end
end
