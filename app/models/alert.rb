class Alert < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord

  attr_accessible :record_id, :closed

  DELETE_AFTER = 3.month

  belongs_to :alert_definition
  has_many   :notes, :dependent => :destroy, :as => :noteable

  has_one :organization

  scope :not_closed, { :conditions => { :closed => false }}
  scope :last_ones,  { :order      => 'alerts.created_at DESC' }
  
  validates_presence_of :closed_at, :if => :closed
  
  scope :include_in, { :include => :alert_definition }
  
  scope :can_see, lambda{ |agent|

    watched_tables_for_user = []
    AlertDefinition.all.map(&:watched_table).uniq.each do |watched_table|
      if agent.is_a?(User) and agent.has_any_permission_to(:read, watched_table)
        watched_tables_for_user << watched_table
      end
    end

    watched_strings = []
    watched_tables_for_user.each do |watched_table|
      watched_objects = watched_table.singularize.camelize.constantize.can_see(agent).map(&:id)
      watched_strings << "(alert_definitions.watched_table = '#{ watched_table }' AND alerts.record_id IN (#{ watched_objects.join(', ') }))" if !watched_objects.empty?
    end

    { :conditions => [ "#{ watched_strings.join(' OR ') }"] }

  }
  
  acts_as_container

  authorizing do |user, permission|
    case alert_object.class
      when Interested
        alert_object.local_organization.authorize?([permission, :LocalOrganization], :to => user, :default => nil)
    end
  end
  
  authorizing do |user, permission|
    (permission == :update and user.is_a?(User) and user.has_any_permission_to(:update, :alerts) and alert_object.authorize?(:read, :to => user)) || nil
  end
  
  authorizing do |user, permission|
    permission == :read and user.is_a?(User) and user.has_any_permission_to(:read, :alerts) and alert_object.authorize?(:read, :to => user)
  end
  
 
  def self.fast_search_fields
    ['alert_definitions.name', 'alerts.created_at' ]
  end
  
  
  def self.last_alert
    Alert.last_ones.first
  end
  
  # PUFFFF omg!
  def alert_object
    alert_definition.watched_table.singularize.camelize.constantize.find(:first, :conditions => { :id => record_id })
  end

  # Explanation of the alert
  def h_record
    record = Object::const_get(self.alert_definition.watched_table.classify).find_by_id( record_id )
    if record.nil?
      I18n.t('record_not_found');
    elsif record.respond_to?(:h)
      record.h
    elsif record.respond_to?(:full_name)
      record.full_name
    elsif record.respond_to?(:title)
      record.title
    elsif record.respond_to?(:name)
      record.name
    else
      record.class.name
    end
  end

  def full_name
    h_alert_definition + " " + h_record
  end
  
  def to_title
    full_name
  end
  
  def h_alert_definition
   alert_definition_id.nil? ? "" : alert_definition.name
  end


  def validate
    if closed_at.nil? == false
      if closed_at > Date.today
        self.errors.add :base, :closed_date_future
      end
    end
  end

  def self.searcheable_fields
    [unhideable_fields, hideable_fields, 'alert_definition.name' ].flatten
  end

  def self.unhideable_fields
    [ 'created_at', 'closed', 'closed_at' 
    ]
  end

  def self.hideable_fields
    [
      #'alert_definition.days_for_triggering'
    ]
  end
  
  def self.conditions_columns 
    { :cont   => [ 
                 ],
      :eq => ['alert_definition.name', 'closed', 'days_for_triggering'
                 ],
      :date   => [ 'created_at', 'closed_at' ] }
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
  
end

