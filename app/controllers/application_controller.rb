class ApplicationController < ActionController::Base
  protect_from_forgery

#  include ExceptionNotification::Notifiable

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
#  filter_parameter_logging :password

  authentication_filter

  # session expired
  before_filter :session_expired_control
  # control user log id
  after_filter :log_user_id

  alias_method :current_user, :current_agent 

  def session_expired_control
    # session expire time 20 min
    now =  Time.now
    max_inactive_minutes = 30

    if now > (session[:last_request_time] + max_inactive_minutes.minutes)
      reset_session
      flash[:error] = t(:session_expired, :max_time_inactive => t('datetime.distance_in_words.x_minutes.other', :count => max_inactive_minutes))
      redirect_back_or_default(login_path)
    else
      session[:last_request_time] = now
    end
  end
  
  def log_user_id
    log_user_name = current_user ? "#{ current_user.id } #{ current_user.login }" : 'anonymous'
    logger.info "Action performed by logged user: #{ log_user_name }"
  end

end

