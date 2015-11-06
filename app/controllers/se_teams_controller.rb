class SeTeamsController < ApplicationController
  include ActionController::AIOrganizationController

  authorization_filter :create, :se_team, :only => [ :new, :create ]
  # Organizations can be listed for all.
  # authorization_filter :read,   :se_team, :only => [ :show, :index ]
  authorization_filter :update, :se_team, :only => [ :edit, :update]
  authorization_filter :destroy, :se_team, :only => [ :delete, :destroy ]
  
  before_filter :set_enable, :only => [ :create ]

  private
  def set_enable
    @se_team.enabled = true
  end


end
