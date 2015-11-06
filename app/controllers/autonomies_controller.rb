class AutonomiesController < ApplicationController
  include ActionController::AIOrganizationController

  authorization_filter :create, :autonomy, :only => [ :new, :create ]
  # Organizations can be listed for all.
  # authorization_filter :read,   :autonomy, :only => [ :show, :index ]
  authorization_filter :update, :autonomy, :only => [ :edit, :update]
  authorization_filter :destroy, :autonomy, :only => [ :delete, :destroy ]
  
  before_filter :set_enable, :only => [ :create ]
  
  def autonomic_teams_for
    autonomy = params[:organization_id].nil? || params[:organization_id].empty? ? nil : Autonomy.find(params[:organization_id])
    render :partial => 'autonomic_teams_for', :layout => false, :locals => {:autonomy => autonomy}
  end
  
  private
  def set_enable
    @autonomy.enabled = true
  end

end
