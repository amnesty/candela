class CampaignactionsController < ApplicationController
  
  include ActionController::AIController

  
  authorization_filter :create, :campaignaction, :only => [ :new, :create ]
  authorization_filter :read,   :campaignaction, :only => [ :show, :index ]
  authorization_filter :update, :campaignaction, :only => [ :edit, :update]
  authorization_filter :destroy, :campaignaction, :only => [ :delete, :destroy ]
  
  before_filter :set_organization_type,         :only => [ :create ]
  before_filter :set_organization_by_container, :only => [ :new, :create ]
  
  def index
    if current_container
      super(:query_to => current_container.campaignactions)
    else
      @campaignactions = Campaignaction.can_see(current_agent).include_in(:organization).all
      @campaignactions.sort! { |a,b| a.organization.name.to_s.parameterize.to_s <=> b.organization.name.to_s.parameterize.to_s }
      render :template => 'campaignactions/index_by_organizations'            
    end
  end

  
  private
  def set_organization_type
    if params[:campaignaction] and params[:campaignaction][:organization_type]
      if params[:campaignaction][:organization_type].empty?
        flash[:error] = Gx.t_error("campaignaction.organization_type.empty")
      else
        @campaignaction.organization_type = params[:campaignaction][:organization_type]
      end
    end
      
    if params[:campaignaction] and params[:campaignaction][:organization_type] and params[:campaignaction][:organization_id]
      @campaignaction.organization = params[:campaignaction][:organization_type].constantize.find(params[:campaignaction][:organization_id]) if @campaignaction.organization.nil?
    end                                                     
  end
  
  def set_organization_by_container
    @campaignaction.organization = current_container if current_container
  end
end
