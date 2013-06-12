class LocalOrganizationsController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :local_organization, :only => [ :new, :create ]
  
  # Organizations can be listed for all.
  # authorization_filter :read,   :local_organization, :only => [ :show  ]
  
  authorization_filter :update, :local_organization, :only => [ :edit, :update]
  authorization_filter :destroy, :local_organization, :only => [ :delete, :destroy ]

  before_filter :set_enable, :only => [ :create ]
      
  private
  def set_enable
    @local_organization.enabled = true
  end
end
