require_dependency "#{ Rails.root }/vendor/gems/station/app/controllers/sessions_controller"

class SessionsController

  skip_before_filter :authentication_required, :session_expired_control

  after_filter :set_expire_time, :only => [ :create ]

  def after_create_path
    flash[:success] = nil
    root_path
  end

  private
  def set_expire_time
    if current_agent != Anonymous.current
      session[:last_request_time] = Time.now
    end
  end

  def gen_alerts
    la = Alert.last_alert
    if la.nil? == false
      if la.created_at.to_date == Time.now.to_date
        return
      end
    end
    AlertDefinition.gen_all rescue flash[:error] = t('alert.error_creating')
  end

end
