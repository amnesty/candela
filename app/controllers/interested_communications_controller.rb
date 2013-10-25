class InterestedCommunicationsController < ApplicationController
  include ActionController::AIController

  before_filter :set_resource_with_interested, :only => [ :new, :create ]

  authorization_filter :create, :interested_communication, :only => [ :new, :create ]
  authorization_filter :read, :interested_communication, :only => [ :show, :index ]
  authorization_filter :update, :interested_communication, :only => [ :edit, :update]

  def index
    options = {}
    options[:query_to] = Interested.find(params[:interested_id]).communications if params[:interested_id]
    super(options)
  end

  def set_resource_with_interested
    @interested_communication = @resource = InterestedCommunication.new :event_definition => EventDefinition.find_by_klass('InterestedCommunication'), :item_id => params[:interested_id]
  end

end
