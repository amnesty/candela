#FIXME: INDEPENDIZE dependency from its path!
require_dependency "#{Rails.root}/vendor/gems/station/app/models/performance"

class Performance
  
  include ActiveRecord::AIActiveRecord
  
  attr_accessible :stage_type, :stage_id, :stage_ids, :role_id, :agent_type, :agent_id

  attr_accessor :stage_ids # form multiple performances create
 
  validates_uniqueness_of :agent_id, :scope => [ :agent_type, :role_id, :stage_id, :stage_type ]

  scope :group_by_organization, { :group => "stage_type, stage_id" }
  scope :group_by_role,         { :group => "role_id" }
  #FIXME This should order by organization.name, but, how? as it is polimorphic
  scope :order_by_organization, { :order => "stage_type, stage_id" }
  scope :order_by_role,         { :joins => "INNER JOIN roles ON role_id = roles.id", :order => "roles.name" }
  
  scope :include_in, { :include => [ :agent, :role, :stage ] }

=begin
#   Permissions are assigned to users in two ways, as roles and as organizations.
#   When the setting in site.create_permissions_as_roles is true, all the permissions
#   are created, edited and shown grouped by role, so that one can assign the same role
#   to several organizations. When false, one can assign the same organization to several
#   roles. See the performances view for the form to edit the permissions. 
#   This solve the issue #1414
#   
  I dont think so. nogates
  
=end
  
  def self.stage_types
    ["Site", "LocalOrganization", "SeTeam", "Autonomy", "Country", "Committee", "HrSchool" ]
  end
  
  def to_title
    "#{ h_agent }, #{ h_role }, #{ h_stage }"
  end
    
  
  # FIXME  
  def h_stage
    stage.nil? ? "" : (stage.name || "")
  end

  def h_agent
    agent.nil? ? "" : (agent.name || "")
  end

  def h_role
    role.nil? ? "" : (role.name || "")
  end

  # We want to destroy all the peformances when drop_data:permissions
  def avoid_destroying_only_one_with_highest_role
  end


  
  
  def h_role_name
    self.role.nil? ? '' : role.name
  end
  
  def h_all_roles_names
    ret = ""
    self.agent.performances.each do |user_performance|
      if user_performance.stage_id == self.stage_id && user_performance.stage_type == self.stage_type
        if ret != ""
          ret << ",  "
        end
        ret << user_performance.h_role_name
      end
    end
    ret
  end
  
  def h_all_organizations_names
    ret = ""
    self.agent.performances.each do |user_performance|
      if user_performance.role_id == self.role_id 
        if ret != ""
          ret << ",  "
        end
        ret << user_performance.organization_name
      end
    end
    ret
  end
 
 
  
  def organization_name
    ret = ""
    if self.stage_id and self.stage_type
      return "#{ I18n.t("#{ self.stage_type.underscore }.abrev") } #{ self.stage.name }"
    end
    return I18n.t('activists_collaboration.unknown_organization')
  end
  
  def roles_for_its_organization
    ret = []
    self.agent.performances.each do |user_performance|
      if user_performance.stage_id == self.stage_id && user_performance.stage_type == self.stage_type
        ret << user_performance.role.id
      end
    end
    ret
  end
  
  
  def self.organizations_for_stage(stage_type)
    self.stage_types.include?(stage_type) ? stage_type.constantize.orderby_name : []
#    unless self.stage_types.include?(stage_type)
#      raise ActiveRecord::RecordNotFound
#    end
#    stage_type.constantize.orderby_name
  end
  
end
