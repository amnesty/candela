class HrSchool < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord

  attr_accessible :name, :status, :hr_school_level_ids, :hr_school_level_other, :hr_type, :type_other, :join_at, :leave_at,
                  :address, :cp, :province_id, :city, :phone, :phone2, :fax, :web_page, :email, 
                  :contact_name, :contact_position, :contact_email, :contact_phone, :contact_tweeter, 
                  :is_partner, :is_activist, :direction_approval, :accepted_privacity,
                  :school_management, :assigned_organization_type, :assigned_organization_id,
                  :hr_work_through_ids

  audited :on => [:create,:update,:destroy]
#                  :only => [ :name, :status, :join_at, :leave_at, :contact_name, :direction_approval, :tutor, :assigned_organization_id, :assigned_organization_type ]

  attr_accessor :from_public
  attr_accessor :verify_privacity
  attr_accessor :accepted_privacity

  belongs_to :assigned_organization, :polymorphic => true
  belongs_to :province
  
  has_many :notes, :as => :noteable, :dependent => :destroy
  has_many :hr_school_organization_managers, :dependent => :destroy
  
  has_and_belongs_to_many :hr_work_throughs
  has_and_belongs_to_many :hr_school_levels
  has_and_belongs_to_many :academic_years
  
  after_destroy :clear_hbtm
  before_validation :ensure_assigned_organization
  before_save :check_assigned_organization_alert
 
  validates_uniqueness_of :name

  validates_presence_of :status
  
  validate :status_is_inactive_when_leave_at_comes
  
  validates_numericality_of :cp, :phone, :phone2, :tutor_phone, :on => :save, :allow_blank => true

  validates_length_of :phone,       :is => 9, :allow_blank => true
  validates_length_of :phone2,      :is => 9, :allow_blank => true
  validates_length_of :tutor_phone, :is => 9, :allow_blank => true
  validates_length_of :fax,         :is => 9, :allow_blank => true

  validates_format_of :email, :contact_email, :with => REGEXP_EMAIL, :on => :save, :allow_blank => true
 
  validates_presence_of :address, :cp, :province_id, :city, :phone, :email, :contact_name, :contact_position, :contact_email, :if => Proc.new{|r| r.from_public }

  validates_presence_of :hr_school_level_other, :if => Proc.new{|r| r.hr_school_level_ids.include? 4 }

  validates_presence_of :assigned_organization_type, :assigned_organization_id, :if => Proc.new{|r| r.school_management }

  validate :has_direction_approval,  :if => Proc.new{|r| r.from_public }

  validate :privacity_accepted,  :if => Proc.new{|r| r.verify_privacity }
  
  accepts_nested_attributes_for :hr_school_organization_managers, :reject_if => proc { |m| m.organization.nil? }
  
  scope :include_in, { :include => :hr_work_throughs }
  
  scope :can_see, lambda { |agent|
    options    = {}
    conditions = ''
                               
    if agent.is_a?(User) and !agent.has_any_permission_to(:read, :hr_school, :on => Site.current)
      ps = 
        agent.performances.all(:include    => [ :role => :permissions ],
                               :conditions => [ 'permissions.objective = ? AND performances.stage_type IS NOT NULL AND performances.stage_type != ?', 'HrSchool', 'Site' ]
                               )
       valid_conditions = ps.inject([]) do |valid_stages, performance|
                            valid_stages << "(hr_schools.assigned_organization_id = '#{ performance.stage_id }' AND hr_schools.assigned_organization_type = '#{ performance.stage_type }')"
                            valid_stages << "(can_see_hr_school_organization_managers.organization_id = '#{ performance.stage_id }' AND can_see_hr_school_organization_managers.organization_type = '#{ performance.stage_type }')" 
                            valid_stages
                          end
                               
       if valid_conditions.empty?
          options[:conditions] = [ '1 = 0' ]
       else
         options[:conditions] = [ valid_conditions.join('OR') ] 
       end  
        
       options[:select] = "DISTINCT hr_schools.*"
       options[:joins]  = "INNER JOIN hr_school_organization_managers AS can_see_hr_school_organization_managers ON can_see_hr_school_organization_managers.hr_school_id = hr_schools.id"
    end
    options
  }

  authorizing do |user, permission|
    self.ensure_assigned_organization
    if user.is_a?(User) && self.assigned_organization
      user.has_any_permission_to(permission, :hr_school, :on => self.assigned_organization)
    end || nil
  end
  
  # authorizing though organization_managers relations
  authorizing do |user, permission|
    if user.is_a?(User)
      hr_organizations = self.hr_school_organization_managers.map(&:organization)
      hr_organizations.inject(nil) do |can_do, organization|
        if permission.is_a?(Array)
          perm  = permission.first
          where = permission.last
        else
          perm  = permission
          where = :hr_school
        end
        can_do = user.has_any_permission_to(perm, where, :on => organization) || nil
        can_do
      end
    end || nil
  end
  
  
  scope :can_choose, lambda { |agent|
    conditions = ''
    agent.performances.each do |p|
      if p.stage_type == "HrSchool"
        if conditions != ''
          conditions << ","
        end
        conditions << p.stage_id.to_s
      end
    end
    {
      :conditions => conditions == '' ? '' : "id IN(" << conditions << ")"
    }
  }
  
  acts_as_container
  acts_as_stage
  
  def full_name; name;     end
  def to_title; full_name; end
    
  def self.default_order_field
    "hr_schools.name"
  end
        
  def self.statuses
    I18n.t('hr_school.statuses').values
  end

  def self.hr_types
    I18n.t('hr_school.types')
  end

  def h_city
    (City.find_by_name(city) || City.find_by_id(city)).name if self.city?
  end

  def h_work_throughs
    self.hr_work_throughs.collect { |hrwt| hrwt.name }.join(", ")
  end

  def validate
    r = Gx.validate_address( self.cp, self.province_id, self.city )
    if not r[0]
      self.errors.add :base, r[1]
      return false
    end
    if join_at.nil? == false
      if join_at > Date.today
        self.errors.add :base, :join_date_future
        return false
      end
    end
    if leave_at.nil? == false
      if leave_at > Date.today
        self.errors.add :base, :leave_date_future
        return false
      end
    end
    if join_at.nil? == false && leave_at.nil? == false
      if join_at > leave_at
        self.errors.add :base, :conflicting_dates
        return false
      end
    end
  end
  
  def self.searcheable_fields
    [unhideable_fields, hideable_fields, 'assigned_organization_type', 'assigned_organization_id' ].flatten
  end

  def self.unhideable_fields
    [ 'name', 'status']#, 'activist_status_id' ]
  end

  def self.hideable_fields
    [ 'hr_type', 'type_other', 'hr_school_levels', 'hr_school_level_other', 'join_at', 'leave_at',
      'address', 'cp', 'province_id',  'city',  'phone',  'phone2', 'fax', 'web_page',   'email',  
      '/contact_person', 'contact_name', 'contact_position', 'contact_email', 'contact_phone', 'contact_tweeter', 'is_partner', 'is_activist',
      'direction_approval'
    ]
  end

  def self.conditions_columns
    { :cont   => [ 'name',  'address', 'contact_name', 'contact_position',
                             'tutor', 'type_other', 'hr_school_level_other', 'school_management'  ],
      :eq => ['province_id', 'cp', 'city', 'email', 'phone', 'direction_approval', 'tutor_phone', 'pupils_count',
                  'fax', 'web_page', 'phone2', 'status', 'hr_type' ],
      :date   => [ 'join_at', 'leave_at' ] }
  end
  
  def self.condition_type_for_column(column_name)
    ret = ''
    conditions_columns.each_pair do |key,value|
      ret = key if value.include?(column_name)
    end
    ret
  end
  
  def self.sort_for_csv(items)
    items
  end

  def self.column_translations
    { 
      'city' => { :command => lambda{|value| City.translate_bd_string_to_city_name(value) } },
      'assigned_organization_type' => { :prefix => "activerecord.attributes.activists_collaboration", :transformations => ["underscore"] }
    }
  end
 
  def self.organizations_for(type)
    case type
    when "LocalOrganization"
      organizations = LocalOrganization.orderby_name
    when "Autonomy"
      organizations = Autonomy.orderby_name
    when "SeTeam"
      organizations = SeTeam.available_for_hr_schools.orderby_name
    else
      organizations = []
    end
    organizations
  end

  def ensure_assigned_organization
    if self.assigned_organization_id == ''
      self.assigned_organization_id = nil
    end
    if self.assigned_organization_type == ''
      self.assigned_organization_type = nil
    end
  end

  private

  def has_direction_approval
    self.direction_approval || self.errors.add(:direction_approval, :must_be_true)
  end

  def privacity_accepted
    self.accepted_privacity || self.errors.add(:accepted_privacity, :privacity_must_be_accepted)
  end

  def clear_hbtm
    hr_work_throughs.destroy_all
    hr_school_levels.destroy_all
    academic_years.destroy_all
  end
  
  def status_is_inactive_when_leave_at_comes
    errors.add :base, :status_is_not_inactive_with_leave_at  if status != I18n.t("hr_school.statuses.inactive") and leave_at.present?
  end
  
  def check_assigned_organization_alert
    if self.assigned_organization && (changes.keys & ["assigned_organization_id","assigned_organization_type"]).any?
      begin
        ApplicationMailer.alert_hr_school_assigned(self).deliver 
      rescue MailTemplateException, Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        # If email delivery fails, an error is added but the school is saved.
        errors.add(:email, :undeliverable )
      end
    end
  end
  
  def self.test_assigned_organization
    schools_to_fix = {:none => [], :one => [], :several => []}
    HrSchool.all.each do |school|
      if school.school_management && !school.assigned_organization
        if school.hr_school_organization_managers.empty?
          schools_to_fix[:none] << school 
        elsif school.hr_school_organization_managers.count == 1
          schools_to_fix[:one] << school 
        else    
          schools_to_fix[:several] << school 
        end
      end
    end
    schools_to_fix
  end

end
