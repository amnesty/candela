class Activist < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::AIActivist

  attr_accessible :first_name, :last_name, :last_name2, :sex_id, :birth_day, :document_type, :nif, 
                  :different_residence_country, :address, :cp, :province_id, :city, :phone, :mobile_phone, :email, 
                  :join_at, :other_information, :labour_situation_id, :occupation_id, 
                  :student_previous_degrees, :student, :student_place, :student_level_id, :student_degree, :student_year_id, :student_more_info, 
                  :data_protection_agreement, :informed_through_id, :informed_through_other, :collabtopic_ids, :language_ids, :skill_ids, :other_skills, :hobby_ids, :other_hobbies, :blogger,
                  :leave_at, :leave_reason_id, :leave_more_info

  audited :on => [:create,:update,:destroy]
#                  :only => [:data_protection_agreement, :leave_at, :leave_reason_id ]
  
  REMOVE_DATA_AFTER = 2.year
  SET_TO_LEAVE_AFTER = 6.month

  before_destroy :check_collaborations
   
  belongs_to :leave_reason
  
  has_one :interested
  
  has_many :notes, :dependent => :destroy, :as => "noteable"
  has_many :activists_collaborations, :dependent => :destroy
  has_many :organizations, :through => :activists_collaborations, :source_type => [ LocalOrganization, SeTeam ].join(' OR ')
  
  validates_presence_of     :join_at
  
  validates_format_of       :first_name, :last_name,
                            :with => REGEXP_ONLY_ALPHA, 
                            :on => :save,
                            :message => I18n.t('activerecord.errors.messages.cant_contain_digits'),
                            :if => Proc.new{ |activist| activist.leave_at.nil? }
  
  validates_format_of       :last_name2,
                            :with => REGEXP_ONLY_ALPHA,
                            :on => :save, 
                            :allow_blank => true,
                            :message => I18n.t('activerecord.errors.messages.cant_contain_digits'),
                            :if => Proc.new{ |activist| activist.leave_at.nil? }

  
  validates_numericality_of :cp, :allow_blank => true, :if => Proc.new { |activist| not activist.different_residence_country }
  validates_length_of       :cp, :allow_blank => true, :if => Proc.new { |activist| not activist.different_residence_country }, :is => 5
  
  validates_presence_of :nif
  validates_uniqueness_of :nif, :scope => [ :document_type ], :message => Gx.t_error('activist.nif.already_taken')

  attr_accessor :must_check_unlinked_interested
  validate :check_unlinked_interested 
  validate :join_at_date_not_in_future
  validate :leave_at_date_not_in_future
  validate :conflict_join_and_leave_dates
  validate :valid_spanish_address

  scope :fast_search, lambda { |q| 
	  { :conditions => Activist.fast_search_fields.map{ |field| "#{field} REGEXP '#{ Gx.regexp_acutes(q) }'" }.join(" OR ") } 
  }
  
  scope :with_leave_collaborations, lambda { 
   { :joins => "INNER JOIN activists_collaborations ON activists.id = activists_collaborations.activist_id", :conditions => ['activists_collaborations.activist_status_id = ?', ActivistStatus.leave_id ] }
  }                                                    

  scope :without_collaborations, lambda { 
   { :select => 'activists.*', :joins => "LEFT JOIN activists_collaborations ON activists.id = activists_collaborations.activist_id", :conditions => ['activists_collaborations.activist_status_id IS NULL' ] }
  }                                                    

  scope :with_active_collaborations, lambda { |q|
    if q.nil? || q.empty?
      {}
    elsif Gx.to_boolean(q)
      { :include => "activists_collaborations", :conditions => ['activists.id = activists_collaborations.activist_id AND activists_collaborations.activist_status_id <> ?', ActivistStatus.leave_id ] }
    else
      { :conditions => ["activists.id NOT IN (?)", self.with_active_collaborations(true).collect{|a|a.id} ] }
    end
  }                                                    
  
  scope :without_active_collaborations, lambda { 
    { :conditions => ["activists.id NOT IN (?)", self.with_active_collaborations.collect{|a|a.id} ] }
  }                                                    

  scope :with_related_collaborations_on, lambda { |agent|
    if agent.is_a?(User)
      if agent.has_any_permission_to(:read, :activist, :on => Site.current)
        {}
      else
        ps = agent.performances.all(:include    => [ :role => :permissions ],
                                    :conditions => [ 'permissions.objective = ? AND performances.stage_type IS NOT NULL AND performances.stage_type != ?', 'Activist', 'Site' ]
                                 )
        conditions = ps.collect do |p| 
          if p.stage.is_a? ActiveRecord::AIOrganization
            "(activists_collaborations.organization_id = '#{ p.stage_id }' AND activists_collaborations.organization_type = '#{ p.stage_type }')" 
          elsif p.stage.is_a? AutonomicTeam
            "(activists_collaborations_autonomic_teams.autonomic_team_id = '#{ p.stage_id }')" 
          end
        end 
        conditions = conditions.empty? ? "1 = 0" : conditions.compact.join('OR')
        {:joins => [:activists_collaborations => :autonomic_teams], :conditions => conditions }
      end
    else
      where("1 = 0") # Empty set
    end
  }

  scope :is_partner, lambda { |q| (q.nil? || (q.instance_of?(String) && q.empty?)) ? {} : { :conditions => (Gx.to_boolean(q) ? "partnership_id IS NOT NULL" : "partnership_id IS NULL") } }

  scope :is_leave, lambda { |q| (q.nil? || (q.instance_of?(String) && q.empty?)) ? {} : { :conditions => (Gx.to_boolean(q) ? "leave_at IS NOT NULL" : "leave_at IS NULL") } }

  scope :include_in,  { :include => [ :activists_collaborations ] }

  # Searchs Authorization NamedScope
  scope :can_see, lambda { |agent| {} }
  
  # Objects authorization blocks
  
  # Activist can be CRUD by user if activist belongs to an organization that user has role on.
  authorizing do |user, permission|
    # FIXME
    ret = false
    unless permission.class.is_a?(Array)
      orgs = self.activists_collaborations.map(&:organization) & user.agent_performances.map(&:stage)
      ret = orgs.inject(false) do |valid, o|
              valid || o.authorize?([permission, :Activist], :to => user)
            end || nil
    end
    ret
  end

  # Activist can be CRUD by user if activist belongs to an autonomic team that user has role on.
  authorizing do |user, permission|
    if user.is_a?(User) 
      team_performances = user.agent_performances.select{|p|p.stage_type == 'AutonomicTeam'}
      teams = self.activists_collaborations.collect{|c|c.organization.autonomic_teams if c.organization.is_a? Autonomy}.flatten & team_performances.map(&:stage)
      teams.each do |t|
        return true if user.has_any_permission_to( permission, :Activist, :on => t)
      end
    end
    nil
  end
  
  # Permission to create activist if user has any permission to create
  authorizing do |user, permission|
    if user.is_a?(User) and permission == :create
      user.has_any_permission_to(:create, :activist)
    end || nil
  end 
    
#  # Check permissions based on related interested (disabled)
#  authorizing do |user, permission|
#    if related_int = self.related_interested) 
#      related_int.authorize? permission, :to => user
#    end
#  end
  
  def to_title
    "#{ self.full_name } #{ I18n.t('activist.leave_state', :leave_at => I18n.localize(self.leave_at.to_date)) if self.leave_at.present? }"
  end

  def member_collaborations
    activists_collaborations.select { |collaboration| collaboration.is_member }
  end

  def h_informed_through
   informed_through_id.nil? ? "" : informed_through.name
  end

  def self.fast_search_fields
    ['first_name', 'last_name', 'last_name2', 'nif', 'phone', 'mobile_phone', 'email' ].collect{|f| "activists.#{f}" }
  end

  def self.searcheable_fields
    [unhideable_fields, hideable_fields, 'activists_collaboration.organization_type' , 'activists_collaboration.collaboration_type', 
      'activists_collaboration.activist_status_id', 'activists_collaboration.organization_id', 'activists_collaboration.responsibilities', 'activists_collaboration.expertises' ].flatten
  end

  def self.unhideable_fields
    [ 'first_name', 'last_name', 'last_name2', 'birth_day' ]#, 'activists_collaboration.activist_status_id', 'activists_collaboration.more_info' ]
  end

  def self.hideable_fields
    [ 'sex_id', 'document_type', 'nif', 'different_residence_country', 'address', 'cp',  'province_id', 'city',
      'phone', 'mobile_phone', 'email', 'join_at', 'other_information', 
      'labour_situation_id', 'occupation_id', 'student_previous_degrees',  
      'student', 'student_place', 'student_level_id', 'student_degree', 'student_year_id', 'student_more_info', 
      'data_protection_agreement',  'informed_through_id', 'informed_through_other',
      'other_hobbies', 'other_skills', 'blogger',
      'leave_at', 'leave_more_info', 'leave_reason_id',
      '/skills_params',
      'collabtopics', 'languages', 'skills', 'hobbies'
#      'availability_id', 'organization_id',  'organization_type' , 'collaboration_type',  'activist_status_id' 
    ]
  end

  def self.conditions_columns
    { :cont   => [ 'first_name', 'last_name', 'last_name2', 'nif', 'address', 'informed_through_other', 'student_place',
                    'student_previous_degrees', 'student_more_info', 'other_hobbies', 'leave_more_info', 'other_skills', 'blogger',
                   'other_information', 'email' ],
      :eq => ['document_type', 'province_id', 'cp', 'availability_id', 'organization_id', 'collaboration_type', 
                  'activist_status_id', 'sex_id',  'labour_situation_id', 'student', 'phone', 'mobile_phone',
                   'student', 'data_protection_agreement', 'student_level_id', 'student_year_id', 'student_degree',
                  'city', 'leave_reason_id', 'occupation_id',  'informed_through_id', 'different_residence_country',
                  'organization_type', 'collaboration_type' ],
      :date   => [ 'join_at', 'leave_at', 'birth_day' ] }
  end

  def self.condition_type_for_column(column_name)
    ret = ''
    conditions_columns.each_pair do |key,value|
      ret = key if value.include?(column_name)
    end
    ret
  end
  
  def self.sort_for_csv(items)
    items.sort_by{ |elem| [ elem.last_name.underscore, elem.last_name2.underscore, elem.first_name.underscore ] }
  end

  def validate
    if birth_day.nil? == false
#       if birth_day > Date.today
#         self.errors.add :base, :birth_day_future
#       end
      if( Gx.age( birth_day ) < 14 )
        self.errors.add :base, :age_less_minor
      end
    end

  end

  def self.document_types
    I18n.t('activist.document_types')
  end

#<<<<<H_OCCUPATION
  def h_occupation
   occupation_id.nil? ? "" : occupation.name
  end

  def has_no_active_collaborations
    activists_collaborations.empty? or activists_collaborations.count == activists_collaborations.select{|ac| ac.is_leave }.count
  end
  
  def clear_sensitive_data
    self.first_name    = "id=#{self.id}"
    self.last_name     = "Borrado"
    self.last_name2    = ""
    self.phone         = "999999999"
    self.mobile_phone  = "999999999"
    self.email         = ""
    self.nif           = ""
    self.address       = ""
    self.document_type = "Otros"
  end
  
  def time_to_remove
    if leave_at.nil?
      return 'undefined: Leave_at not set.ERROR'
    else
      return I18n.localize((leave_at + REMOVE_DATA_AFTER).to_date)
    end
  end

  
  def rejoin
    self.leave_at = nil
    self.leave_reason_id = nil
    self.leave_more_info = nil
  end
  
  def activists_collaborations_by_type
    collaborations          = activists_collaborations
    types_of_collaborations = collaborations.sort{ |c, b| c.collaboration_type <=> b.collaboration_type }.map(&:collaboration_type).uniq
    order_hash              = {}
    types_of_collaborations.each do |type|
      order_hash[type] = collaborations.select{ |c| c.collaboration_type == type }
    end
    order_hash
  end

  
  def reference_time_for_leave
    if self.activists_collaborations.count.zero?
      reference_time = self.updated_at
    else
      last_collaboration = self.activists_collaborations.sort{ |a,b| a.updated_at <=> b.updated_at }.last
      reference_time = last_collaboration.updated_at
    end
    reference_time
  end
  
  def time_to_leave
    return I18n.localize((reference_time_for_leave + SET_TO_LEAVE_AFTER).to_date)
  end

  def related_interested    
    Interested.find :last, :conditions => {:document_type => document_type, :nif => nif}
  end
  
  private
  def check_unlinked_interested
    if self.must_check_unlinked_interested
      related_interested = self.related_interested 
      if !related_interested.nil? && related_interested.activist != self
        self.errors.add :base, :interested_already_exists
        return false
      end
    end
  end

  def check_collaborations
    if self.activists_collaborations.any?
      self.errors.add :base, :has_collaborations
      return false
    end
  end
  
  def join_at_date_not_in_future
    if join_at.present? and join_at > Date.today
      self.errors.add :base, :join_date_future
    end
  end
  
  def leave_at_date_not_in_future
    if leave_at.present? and leave_at > Date.today
      self.errors.add :base, :leave_date_future
    end
  end
  
  def conflict_join_and_leave_dates
    if join_at.present? and leave_at.present? and join_at > leave_at
      self.errors.add :base, :conflicting_dates
    end
  end
  
  # FIXME
  def valid_spanish_address
    unless self.different_residence_country.is_a?(TrueClass)
      r = Gx.validate_address( self.cp, self.province_id, self.city )
      if not r[0]
       self.errors.add :base, r[1]
      end
    end
    
  end

#-----------------------------------------------
# EVENT-RELATED CODE
public

  def activist_status_changes
    activists_collaborations.collect{|collab| collab.activist_status_changes }.flatten.compact.sort_by{|ch| [ch.date, ch.created_at]}
  end

end


