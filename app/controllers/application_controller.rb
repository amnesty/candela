class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :authenticate_user!

  after_filter :log_user_id

  alias_method :current_agent, :current_user 
  helper_method :current_agent

protected

  def log_user_id
    log_user_name = current_user ? "#{ current_user.id } #{ current_user.login }" : 'anonymous'
    logger.info "Action performed by logged user: #{ log_user_name }"
  end

end

