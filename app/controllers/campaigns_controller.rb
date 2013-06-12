class CampaignsController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :campaign, :only => [ :new, :create ]
  authorization_filter :read,   :campaign, :only => [ :show, :index ]
  authorization_filter :update, :campaign, :only => [ :edit, :update]
  authorization_filter :destroy, :campaign, :only => [ :delete, :destroy ]

  
  def show_info
    campaign = Campaign.find(params[:campaign_id])
    render :partial => 'campaigns/campaign_info', :locals => { :info_campaign => campaign }, :layout => nil
  end

end
