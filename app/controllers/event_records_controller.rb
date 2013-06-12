class EventRecordsController < ApplicationController
  include ActionController::AIController

  authorization_filter :read, :event_record, :only => [ :show, :index ]
  
  def new
    redirect_to root_path, :notice => t('event_record.cant_be_created')
  end

end
