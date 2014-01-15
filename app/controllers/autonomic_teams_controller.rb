class AutonomicTeamsController < ApplicationController
  
  include ActionController::AIController

  authorization_filter :create,  :resource , :only => [ :new,    :create ]
  authorization_filter :read,    :resource , :only => [ :show,   :index ]
  authorization_filter :update,  :resource , :only => [ :edit,   :update ]
  authorization_filter :destroy, :resource , :only => [ :delete, :destroy ]

  before_filter :set_resource_with_organization, :only => [ :new, :create ]

  def index
    options = {}
    options[:query_to] = Autonomy.find(params[:autonomy_id]).autonomic_teams if current_container.is_a?(Autonomy)
    super(options)
  end

  private

  def set_resource_with_organization
    resource
    set_autonomy
  end

  def set_autonomy
    @autonomic_team.autonomy = current_container if current_container.is_a?(Autonomy)
  end

end
