class HrSchoolOrganizationManager < ActiveRecord::Base
  
  belongs_to :organization, :polymorphic => true
  belongs_to :hr_school

  validates_presence_of :organization
  
  # override default protected attr
  def attributes_protected_by_default
    [ self.class.primary_key ]
  end

  def self.column_translations
    { 
      'organization_type' => { :prefix => "activerecord.attributes.#{self.name.underscore}", :transformations => ["underscore"] }
    }
  end
  
end
