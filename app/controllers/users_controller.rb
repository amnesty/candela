class UsersController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :user,  :only => [ :new, :create ]
  authorization_filter :read,   :user,  :only => [ :show, :index ]
  authorization_filter :update, :user,  :only => [ :edit, :update ]
  authorization_filter :destroy, :user, :only => [ :delete, :destroy ]


end
