class Interested < ActiveRecord::Base
  
  MINOR_AGE_LIMIT = 18
  
  include ActiveRecord::AIActiveRecord
  include ActiveRecord::AIActivist
  
  attr_accessible :first_name, :last_name, :last_name2, :sex_id, :birth_day, :created_at, :document_type, :nif, 
                  :different_residence_country, :cp, :address, :province_id, :city, 
                  :phone, :mobile_phone, :email, :email_2, :local_organization_id, :talk_ids, 
                  :labour_situation_id, :occupation_id, 
                  :student_previous_degrees, :student, :student_place, :student_level_id, :student_degree, :student_year_id, :student_more_info, 
                  :collabtopic_ids, :language_ids, :skill_ids, :other_skills, :hobby_ids, :blogger, :other_hobbies, 
                  :wants_todo, :informed_through_id, :informed_through_other, :how_know_id, :comments,
                  :set_not_interested, :not_interested_at, :not_interested_info, 
                  :minor_checked, :accepted_privacity

  audited :on => [:create,:update,:destroy] 
#                  :only => [:local_organization_id, :activist_id, :minor_checked, :email_sent, :letter_sent ]
  
  attr_accessor :migrate_errors
  attr_accessor :verify_privacity
  attr_accessor :accepted_privacity
  attr_accessor :from_public
  attr_accessor :from_civicrm
  attr_accessor :set_not_interested
  
  validates_presence_of :local_organization_id
  validates_presence_of :document_type, :if => Proc.new{|r| r.from_public }
  validates_presence_of :nif, :if => Proc.new{|r| r.from_public }
  validates_uniqueness_of :nif, :allow_nil => true, :allow_blank => true, :scope => [ :document_type ]  
  validates_format_of :email_2,   :with => ActiveRecord::Base::REGEXP_EMAIL, :allow_blank => true
  validates_presence_of :not_interested_at, :if => Proc.new{|r| Gx.to_boolean(r.set_not_interested) }
  before_validation :check_not_interested_status
  
  belongs_to :local_organization
  belongs_to :activist
  
  belongs_to :how_know
  
  #validates_uniqueness_of :nif, :scope => [ :document_type ]

  before_create :sent_contact_email
  
  validates_format_of :first_name, :last_name, :with => REGEXP_ONLY_ALPHA, :on => :save,
                      :message => I18n.t('activerecord.errors.messages.cant_contain_digits')
  validates_format_of :last_name2, :with => REGEXP_ONLY_ALPHA,
                      :on => :save, :allow_blank => true,
                      :message => I18n.t('activerecord.errors.messages.cant_contain_digits')
  
  validate :privacity_accepted,  :if => Proc.new{|r| r.verify_privacity }, :message => 'kk'
  validate :valid_address,       :if => Proc.new{|r| r.from_public }
  
  validates_numericality_of :cp, :on => :save, :allow_blank => true
  validates_length_of :cp, :is => 5, :allow_blank => true

  validate :validate_civicrm_record, :if => Proc.new{|r| r.from_civicrm }
  
  scope :is_minor, lambda { |q| q.to_s.blank? ? {} : { :conditions => "birth_day" + (Gx.to_boolean(q) ? " > '" : " <= '") + self.minor_birth_date.to_s(:db) + "'" } }
  
  scope :is_activist, lambda { |q| q.to_s.blank? ? {} : (Gx.to_boolean(q) ? where('activist_id IN (?)',Activist.pluck(:id)) : where('activist_id IS NULL OR activist_id NOT IN (?)',Activist.pluck(:id))) }

  scope :has_pending_communication, lambda { |q| q.to_s.blank? ? {} : { :conditions => (Gx.to_boolean(q) ? "(email_sent <> true OR email_sent IS NULL) AND (letter_sent <> true OR letter_sent IS NULL)" : "email_sent = true OR letter_sent = true") } }

  scope :with_talks, lambda { |q| q.to_s.blank? ? {} : (Gx.to_boolean(q) ? {:joins => :talks} : {:conditions => 'interesteds.id NOT IN (SELECT DISTINCT(interested_id) FROM interesteds_talks)' }) }

  scope :filter_not_interested, lambda { |q| q.to_s.blank? ? {} : where("interesteds.not_interested_at IS #{Gx.to_boolean(q) ? ' NOT ' : ''} NULL") }
  
  scope :has_cleared_sensitive_data, lambda { |q| q.to_s.blank? ? {} : where("first_name #{Gx.to_boolean(q) ? '' : 'NOT'} LIKE ? AND last_name #{Gx.to_boolean(q) ? '=' : '<>'} ?", "id=%", "Borrado") }
  
  # Permission to create interested if user has any permission to create
  authorizing do |user, permission|
    if user.is_a?(User) and permission == :create
      user.has_any_permission_to(:create, :interested)
    end || nil
  end 

  # Last authorization block. Interested can be CRUD by user if user has role on its local_organization
  authorizing do |user, permission|
    if user.is_a?(User) and user.has_any_permission_to(permission, :interested)
      user.agent_performances.map(&:stage).include? self.local_organization
    end
  end
    
  def to_title; full_name; end
  def h_local_organization; local_organization_id.nil? ? "" : local_organization.name; end
  def h_occupation;         occupation_id.nil?         ? "" : occupation.name; end
    
  def self.default_order_field
    "interesteds.created_at"
  end
  
  def self.default_order_direction
    "DESC"
  end

  has_many :talk_attendances, foreign_key: "interested_id", class_name: "InterestedsTalk"
  
#TODO: Move to helper
  def sex_presentation
    case self.sex_id
    when 1
      return "Estimado"
    when 2
      return "Estimada"
    else
      return "Estimado/a"
    end
  end

#TODO: Move to helper
  def text_for_local_organization
    "Grupo #{ self.local_organization.name } : #{ self.local_organization.phone } - #{ self.local_organization.email }"
  end
  
#TODO: Move to helper
  def text_for_talk
    %( #{ self.talks.map(&:h).join('<br />') } <br />
       #{ text_for_local_organization } ).html_safe
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

  def cleared_sensitive_data?
    self.first_name == "id=#{self.id}" && self.last_name == "Borrado"
  end
  
  def not_interested? 
    not_interested_at?
  end
  
  def valid_to_migrate?
    if activist.present?
      self.errors.add :base, :already_migrated
      @migrate_errors = self.errors
      return false
    end 
    unless to_activist and activist.valid?
      @migrate_errors = activist.errors
    end
    activist.valid?
  end
    
  def to_activist
    a              = self.build_activist
    migrate_fields = [ :first_name, :last_name, :last_name2, :sex_id, :birth_day, :nif, :address, :province_id, 
                       :cp, :city, :country_id, :phone, :mobile_phone, :email, :labour_situation_id, :student,
                       :student_place, :student_level_id, :student_year_id, :other_languages, :student_degree, 
                       :student_previous_degrees, :document_type, :other_hobbies, :blogger, :student_more_info, 
                       :occupation_id, :languages, :hobbies, :skills, :collabtopics ]
    
    migrate_fields.each do |field|
      a.send("#{ field }=", self.send(field)) 
    end

    a.data_protection_agreement = false
    a.join_at                   = Date.today  
    activist = a
  end

  def to_activist!
    to_activist
    save
  end
  
  def self.minor_birth_date
    Date.today - MINOR_AGE_LIMIT.year
  end

  def is_minor?
    birth_day > Interested.minor_birth_date
  end
  
  
  def validate
    if birth_day.nil? == false

#       if( Gx.age( birth_day ) < MINOR_AGE_LIMIT )
#         self.errors.add :base, :age_less_minor
#       end
    end
    unless different_residence_country
      r = Gx.validate_address( self.cp, self.province_id, self.city )
      if not r[0]
       self.errors.add :base, r[1]
      end
    end
    self.talks.each do |talk|
      ic = InterestedsTalk.interesteds_in_talk(talk).count
      if talk.seats.to_i < ic.to_i
        self.errors.add :base, Gx.t_error("interested.base.more_interesteds_than_seats", :talk => talk.name )
      end
    end
  end

  def validate_civicrm_record
    if email.blank? && phone.blank? && mobile_phone.blank?
      self.errors.add :base, Gx.t_error("interested.base.email_or_phone_required" )
    end
  end
  
  def self.document_types
    I18n.t('activist.document_types')
  end

  def self.fast_search_fields
    ['first_name', 'last_name', 'last_name2', 'nif' ].collect{|f| "interesteds.#{f}" }
  end

  def self.searcheable_fields
    [unhideable_fields, "local_organization_id", hideable_fields, 'not_interested_at', 'not_interested_info' ].flatten
  end

  def self.unhideable_fields
    [ 'first_name', 'last_name', 'last_name2', 'birth_day', 'created_at']
  end

  def self.hideable_fields
    [
      'sex_id', 'document_type', 'nif', 'different_residence_country', 'address', 'cp', 'province_id', 'city',
      'phone', 'mobile_phone', 'email',
      '/studies_params',
      'labour_situation_id', 'occupation_id', 
      'student', 'student_previous_degrees', 'student_place', 'student_level_id', 'student_degree', 'student_year_id', 'student_more_info',
      'informed_through_id', 'informed_through_other',
      'how_know_id', 'comments',
      '/skills_params',
      'other_hobbies', 'other_skills', 'other_languages', 'blogger', 'wants_todo', 
      'collabtopics', 'languages', 'skills', 'hobbies',
      '/communication_params',
      'minor_checked', 'email_sent', 'letter_sent'
    ]
  end
  
  def self.conditions_columns 
    { :cont   => [ 'first_name', 'last_name', 'last_name2', 'nif', 'address', 'email', 'student_previous_degrees', 'student_place', 'student_more_info',
                    'informed_through_other', 'other_hobbies', 'other_skills', 'other_languages', 'blogger', 'wants_todo', 'comments'
                 ],
      :eq => ['sex_id', 'document_type', 'different_residence_country', 'cp', 'province_id', 'city', 'phone', 'mobile_phone', 
                  'labour_situation_id', 'occupation_id', 'student', 'student_level_id', 'student_degree', 'student_year_id',
                  'informed_through_id', 'local_organization_id', 'minor_checked', 'email_sent', 'letter_sent', 'how_know_id'
                 ],
      :date   => [ 'birth_day', 'created_at' ] }
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
  
  # Show only the interesteds of the group logged in
  scope :can_see, lambda { |agent|
    if agent.is_a?(User) and agent.has_any_permission_to(:read, :interested)
      lloo_ids = agent.performances.where(:stage_type => 'LocalOrganization').pluck(:stage_id)
      lloo_ids.any? ? {:conditions => {:local_organization_id => lloo_ids}} : {}
    else
      where('1=0')
    end
  }

  def email_addresses
    ret = []
    ret << email if email?
    ret << email_2 if email_2?
    ret
  end

  def contact_email_body(message_type)
    begin
      ApplicationMailer.contact_email(self, :message_type => message_type).body
    rescue MailTemplateException => e
      I18n.t 'mail_template.errors.missing_template_file'
    end
  end

  def sent_contact_email
    if self.email_addresses.any?
      begin
        ApplicationMailer.contact_email(self, {}).deliver 
        (self.is_minor? || self.email_sent = true)
#      rescue MailTemplateException, Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      rescue 
        # TODO: By now, if contact mail fails, email_sent is not check and an error is added, but interested creation is not stopped. ¿Should it be the behaviour?
        errors.add(:email, :undeliverable )
#        return false
      end
    end
  end
 
  private
  def privacity_accepted
    self.accepted_privacity || self.errors.add(:accepted_privacity, :privacity_must_be_accepted)
  end
  
  def valid_address
    [ :cp, :province_id, :address ].each do |field|
      if not self.send(field) or self.send(field).nil? or self.send(field) == ""
        self.errors.add(field, :must_be_valid)
      end
    end
    
    if not self.city or self.city == I18n.t("country.select_cp_or_province")
      self.errors.add(:city, :must_be_valid)
    end
  end
  
  def check_not_interested_status
    if !self.set_not_interested.nil? && !Gx.to_boolean(self.set_not_interested)
      self.not_interested_at = nil 
    end
  end
  
#-----------------------------------------------
# EVENT-RELATED CODE

  has_many :event_records, :class_name => 'EventRecord', :foreign_key => :item_id, 
                           :include => :event_definition, :conditions => "event_definitions.watched_model = 'Interested'"

  has_many :communications, :class_name => 'InterestedCommunication', :foreign_key => :item_id
  
end



