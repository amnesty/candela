class MailTemplateAssignment < ActiveRecord::Base
  attr_accessible :consumer, :consumer_id, :consumer_type, 
                  :mail_template_collection_id, :template_name

  belongs_to :consumer, :polymorphic => true
  belongs_to :collection, :class_name => 'MailTemplateCollection', :foreign_key => :mail_template_collection_id

  validates_presence_of :collection, :consumer
  validates :mail_template_collection_id, :uniqueness => {:scope => [:consumer_id, :consumer_type]}

  default_scope :include => [:collection]

  def valid_template_name?
    template_name.nil? || template_name.empty? || collection.template_names.include?(template_name) 
  end

  def uses_default_template?
    template_name.nil? || template_name.empty? || !collection.template_names.include?(template_name) 
  end

  def assigned_template_file
    if uses_default_template?
      collection.default_template_file
    else
      "#{collection.folder}/#{template_name}"
    end
  end

end
