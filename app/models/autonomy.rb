class Autonomy < ActiveRecord::Base
  
  attr_accessible :name, :collaborations_enabled, :phone, :address, :cp, :province_id, :city, :email, :email_2, :fax, 
                  :customer_service_time, :meeting_weekday, :meeting_frequency, :meeting_hours, :meeting_venue, 
                  :postal_address, :postal_cp, :postal_province_id, :postal_city, 
                  :delivery_contact, :delivery_phone, :delivery_hours, :delivery_address, :delivery_cp, :delivery_province_id, :delivery_city,
                  :autonomic_team_ids

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::AIOrganization
  include MailTemplateConsumer

  has_many :campaignactions, :as => :organization, :dependent => :destroy
  has_many :custom_actions, :as => :organization, :dependent => :destroy
  has_many :talks, :foreign_key => :organization_id, :conditions => "organization_type = 'Autonomy'", :dependent => :destroy
  has_many :autonomic_teams, :dependent => :destroy
  
  has_many :assigned_hr_schools, :as => :assigned_organization, :class_name => 'HrSchool', :dependent => :restrict
  has_many :hr_school_organization_managers, :as => :organization, :dependent => :destroy
  has_many :near_hr_schools, :through => :hr_school_organization_managers, :source => :hr_school, :class_name => 'HrSchool'

  def full_name; name; end

  def to_title;
    "#{ I18n.t("autonomy.abrev") }: #{ full_name }";
  end
  
#  def check_campaigns
#    if self.campaignactions.any?
#      self.errors.add :base, :has_campaignactions
#      return false
#    end
#  end

  #OPTIMIZE: Maybe this method should be in AIOrganization...
  def active_members_with_responsibility(responsibility_name)
    resp = Responsibility.find_by_name(responsibility_name) 
    managers = activists_collaborations.collect {|c| c.activist if (c.has_responsibility?(resp) && c.is_active && c.is_member) }.compact
  end

  # User can read autonomy if has access to one of its teams
  authorizing do |user, permission|
    if user.is_a?(User) and permission == :read
      matching_teams = user.agent_performances.collect{|p|p.stage if p.stage_type == 'AutonomicTeam'} & autonomic_teams
      return true if matching_teams.any?
    end
    nil 
  end
  
  # Overrides AIOrganization.can_choose to include autonomic teams
  scope :can_choose, lambda { |agent|
    conditions = "#{ self.name.tableize }.enabled = 1"
    if agent.is_a?(User) and not agent.has_any_permission_to(:read, self.name, :on => Site.current)
      can_read = agent.performances.select{|p|  p.stage_type == "#{ self.name }" }.map(&:stage_id) 
      can_read |= agent.performances.select{|p|  p.stage_type == "AutonomicTeam" }.map(&:stage).collect(&:autonomy_id)
      if can_read.any?
        conditions = '' "#{ self.name.tableize }.id IN(#{ can_read.join(',') })"
      else # ensure cant read
        conditions = " 1 != 1 "
      end
    end 
    {  :conditions => "#{ conditions }" }
  }

end

