class LocalOrganization < ActiveRecord::Base

  attr_accessible :number, :group_type, :name, :collaborations_enabled, :phone, :address, :cp, :province_id, :city, 
                  :show_to_interesteds, :email, :email_2, :fax, :customer_service_time, 
                  :meeting_weekday, :meeting_frequency, :meeting_hours, :meeting_venue, 
                  :postal_address, :postal_cp, :postal_province_id, :postal_city, 
                  :delivery_contact, :delivery_phone, :delivery_hours, :delivery_address, :delivery_cp, :delivery_province_id, :delivery_city

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::AIOrganization
  include MailTemplateConsumer
  
  validates_presence_of :number, :group_type
  validate :validate_group_type
 
  validates_format_of :number, :with => REGEXP_ET_NUMBER, :on => :save, :allow_blank => false,
                      :message => I18n.t("activerecord.errors.models.local_organization.attributes.number")

  has_many :campaignactions, :as => :organization, :dependent => :destroy
  has_many :custom_actions, :as => :organization, :dependent => :destroy
  has_many :talks, :foreign_key => :organization_id, :conditions => "organization_type = 'LocalOrganization'", :dependent => :destroy

  has_many :assigned_hr_schools, :as => :assigned_organization, :class_name => 'HrSchool', :dependent => :restrict
  has_many :hr_school_organization_managers, :as => :organization, :dependent => :destroy
  has_many :near_hr_schools, :through => :hr_school_organization_managers, :source => :hr_school, :class_name => 'HrSchool'

  scope :include_in, { :include => :province }
  scope :only_to_interesteds, { :conditions => { :show_to_interesteds => true, :enabled => true }}
  scope :scoping_with_agent, lambda { |agent|
    options = {}
    if not agent.nil? and agent.is_a?(User) and not agent.has_any_permission_to(:read, :local_organization, :on => Site.current)
      lo_ids = agent.permissions.select{|p| p[:stage_type] == 'LocalOrganization' }
      if lo_ids.any?
       options[:conditions] = "local_organizations.id IN (#{ lo_ids.map{|p| p[:stage_id]}.join(',') })"
      end
    end
    options  
  }
  
  def self.available_group_types
    I18n.t('local_organization.group_types')
  end

  def self.allowed_group_type?(group_type)
    self.available_group_types.keys.collect{|k|k.to_s}.include? group_type.to_s
  end
  
  def validate_group_type
    self.errors.add(:group_type, :invalid) if !LocalOrganization.available_group_types.keys.collect{|k|k.to_s}.include? group_type
  end
  
  def from_madrid
    self.province == Province.find_by_name('Madrid')
  end

  def full_name
    I18n.t("local_organization.abrev") + " " + name
  end

  def to_title
    full_name
  end
  
  def self.fast_search_fields
    [ 'local_organizations.name', 'local_organizations.number' ]
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

end


