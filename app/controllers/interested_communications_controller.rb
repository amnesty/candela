class InterestedCommunicationsController < ApplicationController
  include ActionController::AIController

  prepend_before_filter :add_params_for_new_communication, :only => [ :new ]

  authorization_filter :create, :interested_communication, :only => [ :new, :create ]
  authorization_filter :read, :interested_communication, :only => [ :show, :index ]
  authorization_filter :update, :interested_communication, :only => [ :edit, :update]

  def index
    options = {}
    options[:query_to] = Interested.find(params[:interested_id]).communications if params[:interested_id]
    super(options)
  end

  def add_params_for_new_communication
    params[:interested_communication] ||= {}
    params[:interested_communication][:event_definition_id] = EventDefinition.find_by_klass('InterestedCommunication').id
    params[:interested_communication][:item_id] = params[:interested_id]
  end

end
