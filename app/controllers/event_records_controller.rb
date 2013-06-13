class EventRecordsController < ApplicationController
  include ActionController::AIController

  authorization_filter :read, :event_record, :only => [ :show, :index ]

  def index
    options = {}
    options[:query_to] = params[:type].constantize if defined?(params[:type].constantize)
    super(options)
  end
  
  def new
    redirect_to root_path, :notice => t('event_record.cant_be_created')
  end

end
