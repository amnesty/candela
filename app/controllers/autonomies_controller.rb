class AutonomiesController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :autonomy, :only => [ :new, :create ]
  # Organizations can be listed for all.
  # authorization_filter :read,   :autonomy, :only => [ :show, :index ]
  authorization_filter :update, :autonomy, :only => [ :edit, :update]
  authorization_filter :destroy, :autonomy, :only => [ :delete, :destroy ]
  
  before_filter :set_enable, :only => [ :create ]
  
  
  private
  def set_enable
    @autonomy.enabled = true
  end

end
