class InterestedCommunicationsController < ApplicationController
  include ActionController::AIController

  authorization_filter :read, :interested_communication, :only => [ :show, :index ]
  
  def index
    options = {}
    options[:query_to] = Interested.find(params[:interested_id]).communications
    super(options)
  end

  def new
    @resource = InterestedCommunication.new :event_definition => EventDefinition.find_by_klass('InterestedCommunication'), :item_id => params[:interested_id]
    super
  end

end
