class UsersController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :user,  :only => [ :new, :create ]
  authorization_filter :read,   :user,  :only => [ :show, :index ]
  authorization_filter :update, :user,  :only => [ :edit, :update ]
  authorization_filter :destroy, :user, :only => [ :delete, :destroy ]

  prepend_before_filter :remove_password_if_blank, :only => [ :update ]

  def index
    options = {
        :sort => lambda { |uu| uu.order('users.last_sign_in_at IS NULL, users.last_sign_in_at DESC') }
      }
    super(options)
  end
  
private

  def remove_password_if_blank
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user] = params[:user].except(:password, :password_confirmation)
    end
  end

end
