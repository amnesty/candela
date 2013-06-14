class ActivistsCollaboration < ActiveRecord::Base
  
  # FIXME dry this model
  
  include ActiveRecord::AIActiveRecord

  attr_accessible :activist_id, :collaboration_type, :organization_type, :organization_id, 
                  :autonomy_type, :autonomic_team_ids,
                  :join_at, :more_info, :activist_status_id, :activist_status_changed_at,
                  :responsibility_ids, :availability_id
 
  audited
 
  # Class has no fast search
  def self.has_fast_search?; false; end

  belongs_to :activist
  belongs_to :activist_status
  belongs_to :availability
  belongs_to :autonomy, :class_name => "Autonomy", :foreign_key => "collaboration_id"
  belongs_to :country, :class_name => "Country", :foreign_key => "collaboration_id"
  belongs_to :organization, :polymorphic => true

  has_and_belongs_to_many :autonomic_teams
  has_and_belongs_to_many :responsibilities
  has_and_belongs_to_many :expertises
  
  acts_as_content :reflection => :organization

  after_destroy :clear_hbtm

  def clear_hbtm
    responsibilities.destroy_all
    expertises.destroy_all
  end

  before_save       :record_leave_at
  before_validation :record_new_activist_status

  # Don't include organization_type because usually it is hidden in the forms
  validates_presence_of :activist_id, :organization_id, :collaboration_type, :join_at, :activist_status_id, :activist_status_changed_at

  validates_uniqueness_of :activist_id, :scope => [:organization_id, :organization_type, :collaboration_type], :message => I18n.t('activists_collaboration.errors.already_exists')

  scope :active, lambda { |q|
    { :conditions => [ 'leave_at IS NULL' ] }
  }
  
  scope :active_status, lambda { |q| 
    { :conditions => [ "activist_status_id != ?", ActivistStatus.leave_id ] }
  }

  scope :orderby_name, { :joins => :activist, :order => 'activists.last_name, activists.last_name2, activists.first_name'  }
  scope :include_in, { :include => :organization }
  scope :by_ids, lambda { |ids| 
                                 ids.is_a?(Array) and ids.any? ? 
				  { :conditions => [ "activists_collaborations.id IN(#{ ids.map(&:to_i).join(',') })" ] } : {}				
                                }
  
  scope :by_ids, lambda { |ids| 
                                 ids.is_a?(Array) and ids.any? ? 
				  { :conditions => [ "activists_collaborations.id IN(#{ ids.map(&:to_i).join(',') })" ] } : {}				
                                }

  scope :by_multiple_collaboration_ids, lambda { |ids| 
    ret = {}
    unless ids.nil? || ids.empty?
      collaboration_types_str = ids.collect{|type| "'#{type}'"}.join(',')
      ret = {:conditions => "activists_collaborations.collaboration_type IN (#{collaboration_types_str})"}
    end
    ret
  }
  
#  scope :by_multiple_collaboration_ids, lambda { |ids|
#            ret = {}
#                                                   
#            unless ids.nil?
#                ret                 = { :joins => [], :conditions => [] }
#                count               = 0
#                relation_table_name = "activists_collaborations"
#                ids = [*ids]
#                ids.each { |col_type|
#                  
#                  ret[:joins]      << "INNER JOIN `activists_collaborations` AS `activists_collaborations_#{ count }`"
#                  ret[:conditions] << "`activists_collaborations_#{ count }`.activist_id = `activists`.id"
#                  ret[:conditions] << "activists_collaborations_#{ count }.collaboration_type = '#{ col_type }'"
#                  count += 1
#                }
#                ret[:conditions] = ret[:conditions].join(' AND ')                              

#            end
#            ret
#          }

  # Authorization blocks.
  # User can operate over collaboration if has permission over organization collaboration belongs to 
  authorizing do |user, permission|
    ret = nil
    if organization and user.is_a?(User)
      ret = (user.has_any_permission_to(permission, self.class, :on => organization) || nil)
    end
    ret 
  end
  
  # Authorization blocks.
  # User can operate over collaboration if has permission over activist
  authorizing do |user, permission|
    ret = nil
    if organization and user.is_a?(User)
      ret = (user.has_any_permission_to(permission, self.class, :on => organization) || nil)
    end
    ret 
  end

  # Authorization blocks.
  # User can operate over collaboration if activist is defined, activist has an interested an activist has zero collaborations
  authorizing do |user, permission|
    permission == :create and self.activist and self.activist.interested and self.activist.activists_collaborations.empty? || nil
  end
  
  authorizing do |user, permission|
    user.is_a?(User) and permission == :create and user.has_any_permission_to(permission, self.class)
  end

  
  scope :can_see, lambda { |agent|
    
    conditions = ''
    options    = {  }                           
          
    # whole site read activist permission                          
    if agent.is_a?(User) and not agent.has_any_permission_to(:read, :activists_collaborations, :on => Site.current)
      ps = 
        agent.performances.all(:include    => [ :role => :permissions ],
                               :conditions => [ 'permissions.objective = ? AND performances.stage_type IS NOT NULL AND performances.stage_type != ?', 'Activist', 'Site' ]
                               )
      options[:conditions] = [ ps.map{ |p| "(activists_collaborations.organization_id = '#{ p.stage_id }' AND activists_collaborations.organization_type = '#{ p.stage_type }' AND activists_collaborations.activist_status_id != #{ ActivistStatus.inactive_id })" }.join(' OR ') ]
    end
    options
  }
    
# Set organization_type from collaboration_type
#   def updateOrganizationType
#     self.organization_type = guess_organization_type
#   end

  def record_leave_at
    if self.changes.include?("activist_status_id") and self.activist_status_id == ActivistStatus.leave_id
      self.leave_at = Time.now
    end
  end
  
  def record_new_activist_status
    if self.activist_status_id.nil?
      self.activist_status_id         = ActivistStatus.active_id
      self.activist_status_changed_at = Time.now
    end
  end

  def self.activist_member_collaboration_types
    [
      'MemberLocalOrganization',
      'MemberSeTeam',
      'MemberCountry',
      'MemberAutonomy',
      'MemberCommittee'
    ]
  end

  def self.activist_support_collaboration_types
    [
      'SupportLocalOrganization',
      'SupportSeTeam',
      'SupportCountry',
      'SupportAutonomy'
    ]
  end

  def self.activist_casual_collaboration_types
    [
      'CasualLocalOrganization',
      'CasualSeTeam',
      'CasualCountry',
      'CasualAutonomy'
    ]
  end

  def self.activist_expertise_collaboration_types
    [
      'ExpertiseLocalOrganization',
      'ExpertiseSeTeam',
      'ExpertiseAutonomy',
      'ExpertiseCountry'
    ]
  end


  def self.activist_autonomy_collaboration_types
    [
      'AutonomyAutonomy',
      'ExpertiseAutonomy',
      'CasualAutonomy',
      'SupportAutonomy'
    ]
  end

  def self.activist_country_collaboration_types
    [
      'CountryCountry',
      'ExpertiseCountry',
      'CasualCountry',
      'SupportCountry'
    ]
  end

  def self.local_organization_collaboration_types
    [
      'MemberLocalOrganization',
      'SupportLocalOrganization',
      'CasualLocalOrganization',
      'ExpertiseLocalOrganization'
    ]
  end

  def self.se_team_collaboration_types
    [
      'MemberSeTeam',
      'SupportSeTeam',
      'CasualSeTeam',
      'ExpertiseSeTeam'
    ]
  end

  def self.autonomy_collaboration_types
    [
      'MemberAutonomy',
      'AutonomyAutonomy',
      'SupportAutonomy',
      'CasualAutonomy',
      'ExpertiseAutonomy'
    ]
  end

  def self.country_collaboration_types
    [
      'MemberCountry',
      'CountryCountry',
      'SupportCountry',
      'CasualCountry',
      'ExpertiseCountry'
    ]
  end

  def self.committee_collaboration_types
    [
      'MemberCommittee'
    ]
  end

  def self.collaboration_types
    self.activist_member_collaboration_types.concat(
      self.activist_support_collaboration_types.concat(
        self.activist_casual_collaboration_types.concat(
            self.activist_expertise_collaboration_types) ) )
  end

  def self.organization_collaboration_types
      [ :member, :support, :casual, :expertise ]
  end

  def guess_collaboration_type
    self.class.organization_collaboration_types.each do |type|
      if self.send("is_#{ type }")
        return type
        break
      end
    end
  end

  
  def collaboration_type_list
    return ActivistsCollaboration.organizations_by_type(collaboration_type)  
  end
  
  # Get organizations for HTML SELECTS in activists_collaborations and search forms
  def self.organizations_by_type(coltype)
    # complete: collaboration_type
    if ActivistsCollaboration.local_organization_collaboration_types.index(coltype)
      return LocalOrganization.orderby_name
    elsif ActivistsCollaboration.se_team_collaboration_types.index(coltype)
      return SeTeam.orderby_name
    elsif  ActivistsCollaboration.autonomy_collaboration_types.index(coltype)
      return Autonomy.orderby_name
    elsif ActivistsCollaboration.country_collaboration_types.index(coltype)
      return Country.orderby_name
    elsif ActivistsCollaboration.committee_collaboration_types.index(coltype)
      return Committee.orderby_name
    else
      return [ Country.new( :id => 0, :name => I18n.t("activists_collaboration.membership") ) ]
    end
  end

  def guess_organization_type
    coltype = collaboration_type
    # complete: collaboration_type
    if ActivistsCollaboration.local_organization_collaboration_types.index(coltype)
      return "LocalOrganization"
    elsif ActivistsCollaboration.se_team_collaboration_types.index(coltype)
      return "SeTeam"
    elsif ActivistsCollaboration.country_collaboration_types.index(coltype)
      return "Country"
    elsif  ActivistsCollaboration.autonomy_collaboration_types.index(coltype)
      return "Autonomy"
    elsif ActivistsCollaboration.committee_collaboration_types.index(coltype)
      return "Committee"
    else
      return ""
    end
  end


  def is_member
    ActivistsCollaboration.activist_member_collaboration_types.include?(collaboration_type)
  end

  def is_expertise
    ActivistsCollaboration.activist_expertise_collaboration_types.include?(collaboration_type)
  end

  def is_autonomy
    ActivistsCollaboration.activist_autonomy_collaboration_types.include?(collaboration_type)
  end

  def is_country
    ActivistsCollaboration.activist_country_collaboration_types.include?(collaboration_type)
  end

  def is_support
    ActivistsCollaboration.activist_support_collaboration_types.include?(collaboration_type)
  end

  def is_casual
    ActivistsCollaboration.activist_casual_collaboration_types.include?(collaboration_type)
  end

  def is_se_team
    ActivistsCollaboration.se_team_collaboration_types.include?(collaboration_type)
  end

  def is_committee
    ActivistsCollaboration.committee_collaboration_types.include?(collaboration_type)
  end

  def is_active
    activist_status_id == ActivistStatus.active_id
  end

  def is_inactive
    activist_status_id == ActivistStatus.inactive_id
  end

  def is_internship
    activist_status_id == ActivistStatus.internship_id
  end

  def is_leave_proposed
    activist_status_id == ActivistStatus.leave_proposed_id
  end

  def is_leave
    activist_status_id == ActivistStatus.leave_id
  end

  def must_have_responsability
    is_member || (is_autonomy && is_expertise == false ) ||
      ['SupportLocalOrganization', 'SupportSeTeam', 'SupportAutonomy', 'SupportCountry' ].index(collaboration_type) != nil
  end

  def must_have_extra_autonomy_fields
    (is_autonomy && is_expertise == false ) || collaboration_type == 'MemberAutonomy'
  end


  def organization_name
    ret = ""
    if self.organization
      if self.organization.name and self.organization_type
        return "#{ I18n.t("#{ self.organization_type.underscore }.abrev") } #{ self.organization.name }"
      end
    end
    return I18n.t('activists_collaboration.unknown_organization')
  end

  def kind
    I18n.t("activists_collaboration.#{ collaboration_type }")
  end

  def self.autonomy_types
    I18n.t('autonomy.types')
  end

  def h_responsibilities
    r = responsibilities.collect{ |x| [x.name] }.join(", ")
    r.blank? ? '---' : r
  end

  def h_expertises
    expertises.collect{ |x| [x.name] }.join(", ")
  end

  def h_responsibilities_and_expertises
    if h_responsibilities.empty? and h_expertises.empty?
      ""
    elsif h_responsibilities.empty?
      h_expertises
    elsif h_expertises.empty?
      h_responsibilities
    else
      h_responsibilities + " / " + h_expertises
    end
  end

  def h_autonomy
    autonomy ? autonomy.name : ""
  end

  def h_country
    country ? country.name : ""
  end

  def validate
    return true if activist.nil? # While creating this object with prepare_create
    if activist_status_changed_at.nil? == false
      if activist_status_changed_at > Date.today
        self.errors.add :base, :status_change_date_future
      end
    end
    if join_at.nil? == false
      if join_at > Date.today
        self.errors.add :base, :join_date_future
      end
    end
    if activist.join_at.present? and join_at.present?
      unless activist.join_at.to_date <= join_at.to_date
        self.errors.add :base, :conflicting_dates
      end
    end

  end

  def full_name
    activist.full_name + ": " + kind + ": " + organization_name
  end
  
  def to_title
    full_name
  end


  def self.organization_types
    ["LocalOrganization", "SeTeam", "Autonomy", "Country", "Committee"]
  end

  def h_activist_notes
    ret = ""
    self.activist.activist_notes.each { |note|
     ret << note.toString << "\n"     
    }
    return ret 
  end
  
  def self.column_translations
    { 
      'collaboration_type' => { :prefix => self.name.underscore, :transformations => [] },
      'organization_type' => { :prefix => "activerecord.attributes.#{self.name.underscore}", :transformations => ["underscore"] }
    }
  end

  def has_responsibility?(responsibility)
    responsibilities.include? responsibility
  end

#-----------------------------------------------
# EVENT-RELATED CODE

public

  def activist_status_changes
    ActivistStatusChange.from_activists_collaboration self
  end

end

