class Talk < ActiveRecord::Base

  attr_accessible :name, :organization_type, :organization_id, :date, :address, :hours, :seats  

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::MultipleJoinsConditionForActivist

  audited :on => [:create,:update,:destroy] 
#                  :only => [:name, :date, :address ]

  belongs_to :organization, :polymorphic => true
  
  has_and_belongs_to_many :interesteds
  
  after_destroy :clear_hbtm

  acts_as_content :reflection => :organization
  
  scope :order_by_nexts, lambda{ { :order => 'date ASC' } }

  # authorizing though organization
  authorizing do |user, permission|
    (user.is_a?(User) and user.has_any_permission_to(permission, :talk, :on => organization)) || nil
  end
  
  # Searchs Authorization NamedScope
  scope :can_see, lambda { |agent|
    options    = {}
    conditions = ''
    # whole site read talks permission                          
    if agent.is_a?(User) and not agent.has_any_permission_to(:read, :talk, :on => Site.current)
      ps = 
        agent.performances.all(:include    => [ :role => :permissions ],
                               :conditions => [ 'permissions.objective = ? AND performances.stage_type IS NOT NULL AND performances.stage_type != ?', 'Talk', 'Site' ]
                               )
      options[:conditions] = [ ps.map{ |p| "(talks.organization_id = '#{ p.stage_id }' AND talks.organization_type = '#{ p.stage_type }')" }.join(' OR ') ]
    end
    options
  }
  
  
  def self.default_order_field
    "talks.date"
  end
  
  def self.default_order_direction
    "DESC"
  end

  
  def clear_hbtm
    interesteds.destroy_all
  end

  validates_presence_of :date

  def h_organization
   organization_id.nil? ? "" : organization.to_title
  end

  def h
    I18n.t('talk.texts.complete', :name => name, :address => address, :date => I18n.localize(date.to_date), :hours => hours)
  end
  
  def to_title
    h
  end
  
  def has_place?
    seats.nil? or seats.to_i > interesteds.count 
  end
  
  def info_data
    "Nombre: #{ name }. Fecha: #{ I18n.localize(self.date.to_date) }, #{ self.hours }. Lugar: #{ self.address }"
  end

  def self.searcheable_fields
    [unhideable_fields, hideable_fields, 'organization_type', 'organization_id' ].flatten
  end

  def self.unhideable_fields
    [ 'name', 'date' ]
  end

  def self.hideable_fields
    [
      'address', 'hours', 'seats' #, 'organization_type', 'organization_id'
    ]
  end
  
  def self.conditions_columns 
    { :cont   => [ 'name', 'last_name', 'last_name2', 'nif', 'address', 'email', 'student_previous_degrees', 'student_place', 'student_more_info',
                    'informed_through_other', 'other_hobbies', 'other_skills', 'other_languages', 'blogger', 'wants_todo', 'hours'
                 ],
      :eq => ['seats' #, 'organization_type', 'organization_id'
                 ],
      :date   => [ 'date', 'created_at', 'updated_at' ] }
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
 
  def self.organizations_for(type)
    case type
    when "LocalOrganization"
      organizations = LocalOrganization.orderby_name
    when "Autonomy"
      organizations = Autonomy.orderby_name
    else
      organizations = []
    end
    organizations
  end
 
  def self.column_translations
    { 
      'organization_type' => { :prefix => "activerecord.attributes.activists_collaboration", :transformations => ["underscore"] }
    }
  end

end



