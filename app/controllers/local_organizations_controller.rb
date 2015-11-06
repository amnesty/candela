class LocalOrganizationsController < ApplicationController
  include ActionController::AIOrganizationController

  authorization_filter :create, :local_organization, :only => [ :new, :create ]
  
  # Organizations can be listed for all.
  # authorization_filter :read,   :local_organization, :only => [ :show  ]
  
  authorization_filter :update, :local_organization, :only => [ :edit, :update]
  authorization_filter :destroy, :local_organization, :only => [ :delete, :destroy ]

  before_filter :set_enable, :only => [ :create ]

  def index
    options = {}
    if LocalOrganization.allowed_group_type? params[:group_type]
      options[:conditions] = ["group_type = '#{params[:group_type]}'"] 
      @header_label = I18n.t('form.actions.index', :model => LocalOrganization.available_group_types[params[:group_type].to_sym][:more])
    end
    super(options)
  end
  
  private
  def set_enable
    @local_organization.enabled = true
  end
end
