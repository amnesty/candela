class AlertsController < ApplicationController
  include ActionController::AIController

  authorization_filter :create, :alert, :only => [ :new, :create ]
  authorization_filter :read,   :alert, :only => [ :show, :index ]
  authorization_filter :update, :alert, :only => [ :edit, :update]
  authorization_filter :destroy, :alert, :only => [ :delete, :destroy ]
  
  def new
    redirect_to root_path, :notice => t('alerts.cant_be_created')
  end

  def generate
    num = Alert.all.count
    AlertDefinition.create_alerts
    redirect_to root_path, :notice => "Se han creado #{Alert.all.count - num} nuevas alertas"
  end
  
end
