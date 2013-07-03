class ActivistsController < ApplicationController
  
  include ActionController::AIController

  authorization_filter :create,  :activist, :only => [ :new, :create ]
  authorization_filter :read,    :activist, :only => [ :show ]
  authorization_filter :update,  :activist, :only => [ :edit, :update, :admin_request, :send_admin_request]
  authorization_filter :destroy, :activist, :only => [ :delete, :destroy ]
  
  authorization_filter :leave,   :activist, :only => [ :rejoin, :leave ]
  authorization_filter :clear,   :activist, :only => [ :clear ]
  
  before_filter        :update_different_country_location, :only => [ :create, :update ]
  before_filter        :set_controller_only_validations, :only => [ :create, :update ]

  def set_controller_only_validations
    @resource.must_check_unlinked_interested = true
  end

  # Definitions for filters on index action
  def filters_for_index
    {
      :is_leave => [:is_leave, true],
      :with_related_collaborations => [:with_related_collaborations_on, current_agent]
    }
  end

  # Default values for filters on index action
  def default_filters_for_index
    {
      :with_related_collaborations => true
    }
  end

  def admin_request
  end

  def send_admin_request
    resource
    if params['action'].empty?
      flash[:error] = t('activist.admin_request.no_action')
      redirect_to activist_path(@resource)
    else
      unless ApplicationMailer.activist_admin_request(@resource, current_user, params).deliver
        flash[:error] = t('activist.admin_request.fail_at_send')
      else
        flash[:notice] = t('activist.admin_request.sent_success')
      end
      redirect_to activist_path(@resource)
    end
  end

  def leave
    if activist.leave_at.nil?
      redirect_to url_for(:action => "edit", :section => "leave" )
    else
      redirect_to url_for(:action => "edit", :section => "leave", :show_clear => true )
    end
  end
  
  def clear
    set_resource
    @activist.clear_sensitive_data
    unless @activist.save(:validate => false)
      flash[:error] = @activist.errors.to_xml
    end
    redirect_to url_for(:action => "show")
  end

  def rejoin
    set_resource
    @activist.rejoin
    unless activist.save
      flash[:error] = @activist.errors.to_xml
    end
    redirect_to url_for(:action => "show")
  end
  
  def update
    if params[:activist_leave].present?
      if params[:activist]['leave_at(1i)'].empty? ||
          params[:activist]['leave_at(2i)'].empty? ||
          params[:activist]['leave_at(3i)'].empty?
        flash[:error] = Gx.t_error("activist.base.missing_leave_at")
        redirect_to url_for(:action => "edit",  :section => "leave" )
      elsif @resource.activists_collaborations.active_status.any?
        flash[:error] = Gx.t_error("activist.base.still_active_collaborations")
        redirect_to url_for(:action => "edit",  :section => "leave" )
      else
        resource
        if params[:clear_activist] and @resource.authorize?(:clear, :to => current_agent)
          @resource.clear_sensitive_data
        end
        respond_to do |format|
          format.html {
            if @resource.save(:validate => false)
              flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
              redirect_to :action => :show, :referer => params[:referer]
            else
              flash[:error] = @resource.errors.inspect
              redirect_to url_for(:action => "edit",  :section => "leave" )
            end
          }
        end
      end
      return
    else
      super
    end
  end

  private
  def update_different_country_location
    if params[:different_residence_country]
      @activist.city        = params[:city_different_country]
      @activist.cp          = params[:city_different_country]
      @activist.province_id = 0
    end
  end

end
