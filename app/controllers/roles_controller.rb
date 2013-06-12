class RolesController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :role, :only => [ :new, :create ]
  authorization_filter :read,   :role, :only => [ :show, :index ]
  authorization_filter :update, :role, :only => [ :edit, :update]
  authorization_filter :destroy, :role, :only => [ :delete, :destroy ]
end
