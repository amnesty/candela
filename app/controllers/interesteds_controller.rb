require "erb"
include ERB::Util

class InterestedsController < ApplicationController
  include ActionController::AIController

  
  authorization_filter :create, :interested, :only => [ :new, :create ]
  authorization_filter :read,   :interested, :only => [ :show, :index ]
  authorization_filter :update, :interested, :only => [ :edit, :update, :edit_not_interested, :update_not_interested]
  authorization_filter :destroy, :interested, :only => [ :delete, :destroy ]
  
  # Definitions for filters on index action
  def filters_for_index
    {
      :is_minor => [:is_minor, true],
      :has_pending_communication => [:has_pending_communication, true],
      :is_activist => [:is_activist, true],
      :not_interested => [:filter_not_interested, true],      
      :with_talks => [:with_talks, true]
    }
  end

  # Default values for filters on index action
  def default_filters_for_index
    {
      :is_activist => false,
      :not_interested => false,
    }
  end

  def new
    @resource = Interested.new
    super
  end

  def prepare_mail
    resource
  end

  def prepare_pdf
    resource
  end

  def send_mail
    resource
    
    if params['mailto'].empty?
      flash[:error] = t('interested.no_email_for_sent')
      render :action => :prepare_mail
    else
      !@resource.is_minor? || @resource.minor_checked ? @resource.email_sent = true : nil
      unless @resource.save 
        flash[:error] = t('interested.fail_at_updated')
      else
        unless ApplicationMailer.contact_email(@resource, params).deliver
          flash[:error] = t('interested.fail_at_send_email')
        else
          flash[:notice] = t('interested.email_sent_success')
        end
      end
      redirect_to interesteds_path
    end
  end

  def send_pdf
    resource
    
    body = params['body']
    pdf_string = HtmlToPdf.generate_pdf_string(body)
    sending_success = pdf_string && send_data(pdf_string, :type => "application/pdf", :filename => "letter_#{ @resource.id }.pdf" , :disposition => 'attachment') 
    if sending_success
      !@resource.is_minor? || @resource.minor_checked ? @resource.letter_sent = true : nil
      unless @resource.save 
        flash[:error] = t('interested.fail_at_updated')
      else
        flash[:notice] = t('interested.letter_sent_success')
      end
    else
      error_string = (pdf_string.nil? ? t('interested.fail_at_pdf_generation') : t('interested.fail_at_pdf_sending') )
      redirect_to prepare_pdf_interested_path(@resource), :flash => { :error => error_string }
    end
  end

  def to_activist
    resource
    
    if @resource.is_minor? and not @resource.minor_checked
      flash[:error] = t('interested.cant_be_activist_due_age')
      redirect_to interesteds_path
    elsif request.get?
      if @resource.valid_to_migrate? and @resource.to_activist!
        redirect_to new_activist_activists_collaboration_path(@resource.activist)
      else
        if @resource.migrate_errors
          error_list = @resource.migrate_errors.full_messages
        else
          error_list = @resource.errors.full_messages
          error_list += @resource.activist.errors.full_messages if @resource.activist
        end
        flash[:error] = t('form.actions.not_created', :scope => 'activist' ) +  "<br>" + error_list.join("<br />")
        redirect_to edit_interested_path(@resource)
      end
    end
  end
  
  def edit_not_interested
    resource
  end
  
  def update_not_interested
    resource
    
    if params[:interested][:set_not_interested].nil?
      flash[:error] = t('interested.no_action')
      render :action => :edit_not_interested
    else
      if @resource.save
        flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
        redirect_to update_with_success
      else
        render :action => :edit_not_interested
      end
    end  
  end
  
end
