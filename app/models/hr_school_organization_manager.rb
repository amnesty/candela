class HrSchoolOrganizationManager < ActiveRecord::Base

  attr_accessible :hr_school_id, :organization_type, :organization_id
  
  belongs_to :organization, :polymorphic => true
  belongs_to :hr_school

  validates_presence_of :organization
  
  def self.column_translations
    { 
      'organization_type' => { :prefix => "activerecord.attributes.#{self.name.underscore}", :transformations => ["underscore"] }
    }
  end
  
end
