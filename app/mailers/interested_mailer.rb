# encoding: utf-8
class InterestedMailer < ActionMailer::Base 
  
  default from: Settings.interested_mailer.from 

  def contact_email(interested, params)
    @message_type = params[:message_type] || :email 
    @interested = interested
    template_name = (interested.is_minor? && !interested.minor_checked ? 'contact_email_minors' : 'contact_email')
    mail :to => (params[:mailto] || interested.email), 
         :subject =>  params[:subject] || Gx.t_attr("interested.mail.subject"),
         :template_name => template_name
  end 
   
  def test_email(params)
    mail :to => params[:to], 
         :subject =>  params[:subject] || "Testing email system",
         :body => params[:body] || "This is a test"
  end
   
  def resume_interested_email(local_organization, interesteds)
    @interesteds = interesteds
    mail :to => local_organization.email, 
         :bcc => Settings.interested_mailer.bcc,
         :subject =>  "Listado de Interesados: #{ local_organization.full_name }"
  end

  def resume_alert_email(local_organization, interesteds)
    @interesteds = interesteds
    @local_organization = local_organization
    mail :to => InterestedMailer.organization_recipients_for_alert(local_organization).unshift(local_organization.email), 
         :bcc => Settings.interested_mailer.bcc,
         :subject =>  "Alerta de nuevos interesados: #{ local_organization.full_name }"
  end

  #FIXME: Responsibilities and provinces with supervisor should be defined in settings file.

  def self.organization_recipients_for_alert(local_organization)
    local_organization.active_members_with_responsibility("Gestión activismo").collect{|act| act.email if !act.email.empty?}.compact
  end

  def self.autonomy_recipients_for_alert(local_organization)
    provincies_and_supervisor = {'Madrid' => 'AI Madrid', 'Barcelona' => 'Cataluña'}
    ret = ""
    provincies_and_supervisor.each do |province_name, autonomy_name|
      a = Autonomy.find_by_name(autonomy_name)
      if !a.nil? && !local_organization.province.nil? && local_organization.province.name == province_name
        ret = a.active_members_with_responsibility("Gestión activismo").collect{|am| am.email}.join(', ')
      end
    end  
    ret    
  end

end
