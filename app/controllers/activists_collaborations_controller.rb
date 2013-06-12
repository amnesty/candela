class ActivistsCollaborationsController < ApplicationController

  include ActionController::AIController
  
  before_filter :set_organization_at_new, :only => [ :new ]
  before_filter :set_resource_on_create, :only => [ :create ]

  authorization_filter :create, :activists_collaboration, :only => [ :new, :create ]
  authorization_filter :read,   :activists_collaboration, :only => [ :show, :index ]
  authorization_filter :update, :activists_collaboration, :only => [ :edit, :update]
  authorization_filter :destroy, :activists_collaboration, :only => [ :delete, :destroy ]
  
  before_filter :set_organization, :only => [ :create ]
  before_filter :valid_activist, :only => [ :new ]

  autocomplete :activist, :search

  def index
    options = {}
    options[:query_to] = Activist.find(params[:activist_id]).activists_collaborations if current_container.is_a?(Activist)
    super(options)
  end

  def autocomplete_activist_search
    activists = Activist.fast_search(params[:term])
    render :json => activists.collect{|item| {'id' => item.id.to_s, 'label' => item.full_name, "value" => item.full_name} }
  end

  private
  def set_resource_on_create
    resource
    set_organization
  end
  
  def set_organization
    if current_container.is_a?(Activist)
      @activists_collaboration.organization_id   = params[:activists_collaboration][:organization_id]
      @activists_collaboration.organization_type = params[:activists_collaboration][:organization_type]
    else
      @activists_collaboration.organization = current_container
    end
  end

  def set_organization_at_new
    unless current_container.is_a?(Activist)
      @activists_collaboration.organization = current_container
    else
      @activists_collaboration.activist = current_container
    end
  end
  
  def valid_activist
    if current_container.is_a?(Activist) and current_container.leave_at.present?
      flash[:error] = t('activist.cant_create_collaboration_due_status')
      redirect_to current_container
    end
  end
  
  
end

