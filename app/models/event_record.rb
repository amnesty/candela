class EventRecord < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord

  attr_accessible :event_definition_id, :event_definition, :item, :item_id, :audit, :audit_id, :info

  belongs_to :event_definition
  belongs_to :audit, :class_name => Audited::Adapters::ActiveRecord::Audit

  serialize :info, Hash

  has_many   :notes, :dependent => :destroy, :as => :noteable
  acts_as_container

  validates_presence_of :event_definition

  scope :before, lambda {|date| {:conditions => "timestamp <= '#{date.to_s(:db)}'" } }
  scope :after, lambda {|date| {:conditions => "timestamp > '#{date.to_s(:db)}'" } }

  scope :in_past,   {:conditions => "timestamp <= '#{Time.now.to_s(:db)}'" }
  scope :in_future, {:conditions => "timestamp > '#{Time.now.to_s(:db)}'" }

  scope :for_object, lambda {|obj| {:joins => :event_definition, :conditions => "event_definitions.watched_model = '#{obj.class.name}' AND event_records.item_id = #{obj.id}" } }
  scope :with_codename, lambda { |codename| {:conditions => {:event_definition_id => EventDefinition.first(:conditions => {:codename => codename})} } } 

  scope :include_in, { :include => :event_definition }

#---------------------------
# Child classes management
#---------------------------

  def self.child_classes
    EventDefinition.pluck(:klass).compact.uniq
  end

  def self.inherited(child)
    child.instance_eval do
#      def model_name
#        EventRecord.model_name
#      end
    end
    super
  end

#---------------------------
# Methods for all event types
#---------------------------

  def self.fast_search_fields
    ['event_definitions.name', 'event_records.timestamp' ]
  end

  def event_object
    event_definition.watched_model.constantize.find(:first, :conditions => { :id => item_id })
  end

  def events_for_same_object
    EventRecord.find :all, :joins => :event_definition, :conditions => "event_definitions.watched_model = '#{event_definition.watched_model}' AND event_records.item_id = #{item_id}"
  end

  def full_name
    h_event_definition + " " + h_record
  end
  
  def to_title
    full_name
  end

  def h_event_definition
   event_definition_id.nil? ? "" : event_definition.name
  end

  def h_extra_info
    Gx.t_attr 'event_record.no_extra_info'
  end

  # Description of the associated item
  def h_record
    record = event_object
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

  def self.default_order_field
    "timestamp"
  end

  def self.default_order_direction
    "DESC"
  end

#---------------------------
# Permissions
#---------------------------

  scope :can_see, lambda{ |agent|

    watched_models_for_user = []
    EventDefinition.all_watched_models.each do |watched_model| 
      if agent.is_a?(User) and agent.has_any_permission_to(:read, watched_model)
        watched_models_for_user << watched_model 
      end
    end

    watched_models_for_user.push 'Note' #FIXME: Note model uses 'noteable_type' for permissions, and so it is rejected is the previous checking...

    watched_strings = []
    watched_models_for_user.each do |watched_model|
      watched_objects = watched_model.constantize.can_see(agent).map{ |o| [ o.id ] }
      watched_strings << "(event_definitions.watched_model = '#{ watched_model }' AND event_records.item_id IN (#{ watched_objects.join(', ') }))" if !watched_objects.empty?
    end

    { :include => :event_definition, :conditions => [ "#{ watched_strings.join(' OR ') }"] }
      
  }

  authorizing do |user, permission|
    case event_object.class
      when Interested
        event_object.local_organization.authorize?([permission, :LocalOrganization], :to => user, :default => nil)
    end
  end
  
  authorizing do |user, permission|
    permission == :read and user.is_a?(User) and user.has_any_permission_to(:read, :event_records) and (event_object.nil? || event_object.authorize?(:read, :to => user))
  end

end
