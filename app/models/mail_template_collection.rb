class MailTemplateCollection < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord

  attr_accessible :codename, :description, :default_template_name, :assignments_attributes, :available_consumers_script

  has_many :assignments, :class_name => 'MailTemplateAssignment', :foreign_key => :mail_template_collection_id, :dependent => :destroy
  accepts_nested_attributes_for :assignments

  TEMPLATE_FOLDER = Settings.application_mailer.template_folder
 
  #TODO: authorizations for mail template collections
#  authorizing do |user, permission|
#    true unless permission == :destroy
#  end

  def self.instance_for(collection_or_codename)
    case collection_or_codename
      when MailTemplateCollection
        collection_or_codename
      when Symbol, String
        self.where(:codename => collection_or_codename.to_s).first
      else
        nil
    end
  end

  # Class has no fast search
  def self.has_fast_search?; false; end

  def to_title
    codename
  end

  def available_consumers
   eval available_consumers_script
  end

  def folder
    "#{Rails.root}/#{TEMPLATE_FOLDER}/#{codename.to_s}"
  end

  def template_names
    Dir.glob("#{folder}/*.html.erb").collect{|t|t.gsub("#{folder}/",'').gsub('.html.erb','')}
  end

  def has_template?(template_name)
    File.exists? "#{folder}/#{template_name}.html.erb"
  end

  def valid_default_template? 
    has_template? default_template_name
  end

  def default_template_file
    "#{folder}/#{default_template_name}"
  end

end
