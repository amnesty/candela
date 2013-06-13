
module MailTemplateConsumer
  
  def self.included(base)
    base.class_eval do

      has_many :mail_template_assignments, :as => :consumer

      include InstanceMethods
      extend  ClassMethods
    
    end
  end 

  module ClassMethods
    

  end
  
  module InstanceMethods

    def mail_template_assignment_for(collection_or_codename)
      collection = MailTemplateCollection.instance_for collection_or_codename
      mail_template_assignments.where(:mail_template_collection_id => collection.id).first unless collection.nil?
    end

    def assigned_mail_template_for(collection_or_codename)
      collection = MailTemplateCollection.instance_for collection_or_codename
      assignment = mail_template_assignment_for(collection)
      if assignment
        assignment.assigned_template_file
      else
        collection.default_template_file unless collection.nil?
      end
    end

  end
  
end

  


