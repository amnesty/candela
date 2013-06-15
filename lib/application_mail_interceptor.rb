class ApplicationMailInterceptor

  def self.delivering_email(message)
    message.subject ||= ""
    message.subject.prepend Settings.application_mailer.global_subject_prefix    
  end

end

