# encoding: utf-8
class ApplicationMailer < ActionMailer::Base 
  
  default from: Settings.application_mailer.from 

  def contact_email(interested, params)
    @message_type = params[:message_type] || :email 
    @interested = interested

    mail_with_template :to => (params[:mailto] || interested.email), 
                       :subject =>  params[:subject] || Gx.t_attr("interested.mail.subject"),
                       :body => params[:body],
                       :template_collection => (interested.is_minor? && !interested.minor_checked ? 'contact_minors' : 'contact_interesteds'),
                       :template_consumer => interested.local_organization
  end 
   
  def mail_with_template(params)
    body = params.delete :body
    template_collection = params.delete :template_collection
    template_consumer = params.delete :template_consumer
    mail(params) do |format|
      format.html {
        if params[:body]
          render :text => params[:body]
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

  #FIXME: Responsibilities for receiving mails and provinces with supervisor should be defined in settings file.

  def self.organization_recipients_for_alert(local_organization)
    recipients = local_organization.active_members_with_responsibility("Gestión activismo").collect{|act| act.email if !act.email.empty?}.compact
    recipients.unshift(local_organization.email) if !local_organization.email.empty?
    recipients.unshift(local_organization.email_2) if !local_organization.email_2.empty?
    recipients
  end

  def self.autonomy_recipients_for_alert(local_organization)
    provincies_and_supervisor = {'Madrid' => 'AI Madrid', 'Barcelona' => 'Cataluña'}
    recipients = []
    provincies_and_supervisor.each do |province_name, autonomy_name|
      a = Autonomy.find_by_name(autonomy_name)
      if !a.nil? && !local_organization.province.nil? && local_organization.province.name == province_name
        recipients = a.active_members_with_responsibility("Gestión activismo").collect{|am| am.email}
        recipients.unshift(a.email) if !a.email.empty?
        recipients.unshift(a.email_2) if !a.email_2.empty?
      end
    end  
    recipients  
  end

end
