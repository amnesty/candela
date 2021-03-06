# encoding: utf-8
class ApplicationMailer < ActionMailer::Base 
  
  default from: Settings.application_mailer.from 

  def activist_admin_request(activist, user, params)
    @activist = activist
    @user = user
    @params = params
    mail :to => Settings.application_mailer.activist_leave_request.recipients, 
         :subject =>  Settings.application_mailer.activist_leave_request.subject
  end

  def alert_hr_school_assigned(hr_school, params={})
    @hr_school = hr_school
    @organization = hr_school.assigned_organization

    mail_with_template :to => [@organization.email_addresses], 
                       :subject =>  params[:subject] || I18n.t('hr_school.alert_hr_school_assigned.subject'),
                       :template_collection => 'alert_hr_school_assigned',
                       :template_consumer => @organization
  end 

  def contact_email(interested, params)
    @message_type = params[:message_type] || :email 
    @interested = interested

    mail_with_template :to => (params[:mailto] || interested.email_addresses), 
                       :subject =>  params[:subject] || Gx.t_attr("interested.mail.subject"),
                       :body => params[:body],
                       :template_collection => (interested.is_minor? && !interested.minor_checked ? 'contact_minors' : 'contact_interesteds'),
                       :template_consumer => interested.local_organization
  end 
   
  def mail_with_template(params)
    custom_body = params.delete :body
    template_collection = params.delete :template_collection
    template_consumer = params.delete :template_consumer
    mail(params) do |format|
      format.html {
        if custom_body
          render :text => custom_body
        else
          template_file_name = template_consumer.assigned_mail_template_for template_collection
          begin
            render template_file_name
          rescue ActionView::MissingTemplate => e
            raise MailTemplateException.new :exception => e, :template_collection => template_collection, :template_consumer => template_consumer
          end
        end
      }
    end
  end

  def test_email(params)
    mail :to => params[:to], 
         :subject =>  params[:subject] || "Testing email system",
         :body => params[:body] || "This is a test"
  end
   
  def resume_interested_email(local_organization, interesteds)
    @interesteds = interesteds
    mail :to => local_organization.email, 
         :bcc => Settings.application_mailer.bcc,
         :subject =>  "Listado de Interesados: #{ local_organization.full_name }"
  end

  def resume_alert_email(local_organization, interesteds)
    @interesteds = interesteds
    @local_organization = local_organization
    mail :to => ApplicationMailer.organization_recipients_for_alert(local_organization), 
         :bcc => Settings.application_mailer.bcc,
         :subject =>  "Alerta de nuevos interesados: #{ local_organization.full_name }"
  end

  def civicrm_duplicated_interested_email(civicrm_interested)
    @civicrm_interested = civicrm_interested
    mail :to => @civicrm_interested.email, 
         :bcc => Settings.application_mailer.bcc,
         :subject =>  "Tu email ya está registrado como interesado en colaborar con nosotros"
  end
  
  # Sends weekly interested emails FOR THE WEEK THE PROVIDED DATE IS INTO
  def send_weekly_interesteds_alerts_for(date)
      get_new_interesteds_from_last_week = Interested.find(:all, :conditions => ['created_at >= ? AND created_at < ?', date.beginning_of_week, date.end_of_week ])
      local_organizations = get_new_interesteds_from_last_week.map(&:local_organization).uniq

      local_organizations.each do |lo|
        interesteds = get_new_interesteds_from_last_week.select{|it| it.local_organization_id == lo.id }
        ApplicationMailer.resume_alert_email(lo, interesteds).deliver if interesteds.any?
      end
  end

  #FIXME: Responsibilities for receiving mails and provinces with supervisor should be defined in settings file.

  def self.organization_recipients_for_alert(local_organization)
    recipients = local_organization.active_members_with_responsibility("Gestión activismo").collect{|act| act.email if !act.email.empty?}.compact
    recipients | local_organization.email_addresses
  end

  def self.autonomy_recipients_for_alert(local_organization)
    provincies_and_supervisor = {'Madrid' => 'AI Madrid', 'Barcelona' => 'Cataluña'}
    recipients = []
    provincies_and_supervisor.each do |province_name, autonomy_name|
      a = Autonomy.find_by_name(autonomy_name)
      if !a.nil? && !local_organization.province.nil? && local_organization.province.name == province_name
        recipients = a.active_members_with_responsibility("Gestión activismo").collect{|am| am.email} | a.email_addresses
      end
    end  
    recipients  
  end

end
