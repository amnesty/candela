class CountriesController < ApplicationController
  include ActionController::AIOrganizationController

  authorization_filter :create, :country, :only => [ :new, :create ]
  # Organizations can be listed for all.
  # authorization_filter :read,   :country, :only => [ :show, :index ]
  authorization_filter :update, :country, :only => [ :edit, :update]
  authorization_filter :destroy, :country, :only => [ :delete, :destroy ]

  before_filter :set_enable, :only => [ :create ]
  
  private
  def set_enable
    @country.enabled = true
  end

end
