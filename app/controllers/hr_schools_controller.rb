class HrSchoolsController < ApplicationController
  
  before_filter :set_organization_managers, :only => [ :create, :update ]
  before_filter :delete_organizations_managers, :only => [ :destroy ]

  include ActionController::AIController

  authorization_filter :create, :hr_school, :only => [ :new, :create ]
  authorization_filter :read,   :hr_school, :only => [ :show, :index ]
  authorization_filter :update, :hr_school, :only => [ :edit, :update]
  authorization_filter :destroy, :hr_school, :only => [ :delete, :destroy ]

  before_filter :update_assigned_organization, :only  => [ :update ]
  before_filter :update_organization_managers, :only  => [ :create, :update]
  
  def organizations_for
    @organizations = HrSchool.organizations_for(params[:assigned_organization_type])
    render :template => 'hr_schools/organizations_as_options', :layout => nil
  end

  
  private
  def update_assigned_organization
    if params[:hr_school][:school_management].nil? or  params[:hr_school][:school_management].to_i.zero?
      @hr_school.assigned_organization_id   = nil
      @hr_school.assigned_organization_type = nil
    end
  end
  
  def update_organization_managers
    @hr_school.hr_school_organization_managers << @new_organization_manager if (@new_organization_manager && @new_organization_manager.valid?)
    if @delete_organizations_manager and @delete_organizations_manager.is_a?(Array) and @delete_organizations_manager.any?
      @delete_organizations_manager.each do |id|
        om = HrSchoolOrganizationManager.find(id)
        @hr_school.hr_school_organization_managers.delete(om) if om
      end
    end
  end
  
  def set_organization_managers
    if params[:hr_school] and params[:hr_school][:organization_managers]
      om = params[:hr_school][:organization_managers]
      
      if om[:new] and om[:new][:organization_type] and om[:new][:organization_id]
        @new_organization_manager = HrSchoolOrganizationManager.new(:organization_type => om[:new][:organization_type],
                                                                    :organization_id   => om[:new][:organization_id])
      end
      
      
      if om[:delete] 
        @delete_organizations_manager = om[:delete] 
      end
      
      params[:hr_school].delete(:organization_managers)
    end
  end
  
  def delete_organizations_managers
    params[:hr_school].delete(:organization_managers)
  end

end
