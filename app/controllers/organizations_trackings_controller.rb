class OrganizationsTrackingsController < ApplicationController
  include ActionController::AIController
  
  before_filter :set_user_to_container
  
  authorization_filter :create,  :organizations_tracking, :only => [ :new, :create     ]
  authorization_filter :read,    :organizations_tracking, :only => [ :show, :index     ]
  authorization_filter :update,  :organizations_tracking, :only => [ :edit, :update    ]
  authorization_filter :destroy, :organizations_tracking, :only => [ :delete, :destroy, :destroy_all ]
  
  def index
    super(:query_to => @container.organizations_trackings)
  end
  
  def destroy_all
    @container.organizations_trackings = []
    if @container.save
      flash[:notice] = I18n.t('organizations_tracking.all_destroyed_ok')
    else
      flash[:error]  = I18n.t('organizations_tracking.all_destroyed_fail')
    end
     redirect_to users_path
  end
  
  private
  def set_user_to_container
    @container        = User.find(params[:user_id])
    current_container = @container
  end

end