class OrganizationsTracking < ActiveRecord::Base
  
  attr_accessible :organization_type, :organization_id

  belongs_to :organization, :polymorphic => true
  belongs_to :user
  
  before_create :multiple_creating
  
  validates_presence_of :organization_type, :user_id
  validates_presence_of :organization_id, :unless => Proc.new{|r| r.organization_type == 'all_types' }
  
  include ActiveRecord::AIActiveRecord
  
  acts_as_content         :reflection => :user

  def self.has_fast_search?
    false
  end
  
  authorizing do |user, permission|
    (user.is_a?(User) and user.has_any_permission_to permission, :organizations_tracking) || nil
  end 
  
  def to_title
    I18n.t('organizations_tracking.show_by_user', :user => user.name)
  end
  
  
  def multiple_creating
    organizations = []
    if self.organization_type == 'all_types'
      organizations = ActivistsCollaboration.organization_types.map(&:constantize).map(&:orderby_name).flatten.map{|o| [ o.class.to_s, o.id ]}
    elsif self.organization_id == -1
      if ActivistsCollaboration.organization_types.include?(organization_type)
        organizations = organization_type.constantize.orderby_name.map{|o| [ o.class.to_s, o.id ]}
      else
        raise "Undefined Organization #{ organization_type }"
      end
    else
      organizations = [ [organization_type, organization_id ] ]
    end
    
    last_organization = organizations.pop
    organizations.each do |multiple_organization|
      ot = OrganizationsTracking.new
      ot.user_id = user_id
      ot.organization_type = multiple_organization.first
      ot.organization_id = multiple_organization.last
      ot.save!
    end

    self.organization_type = last_organization.first
    self.organization_id   = last_organization.last
  end
  
end
