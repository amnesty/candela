class EventDefinition < ActiveRecord::Base

  validates_uniqueness_of :name

  serialize :trigger_conditions, Hash

  has_many :event_records, :dependent => :destroy

  scope :for_model, lambda { |model| {:conditions => "watched_model = '#{model}'" } } 
  scope :including_action, lambda { |action| {:conditions => "watched_actions LIKE '%#{action}%'" } } 

  def self.all_watched_models
    EventDefinition.all.map(&:watched_model).uniq
  end

  def includes_action?(action)
    watched_actions.include? action
  end

  def item_class
    watched_model.constantize
  end

#---------------------------------------------------------------
# EVENT CHECKING ON ITEMS

  def self.check_item(item,action)
    events = EventDefinition.for_model(item.class.name).including_action(action.to_s).collect do |event_definition|
      event_definition.create_event(item) if event_definition.triggers_event?(item)
    end
    events.compact
  end

  def create_event(item)
    event = nil
    event = EventRecord.find(:first, :conditions => {:event_definition_id => self, :item_id => item.id}) if is_unique
    if event.nil?
      if self.klass
        event = self.klass.constantize.new({:event_definition => self, :item_id => item.id}) 
      else
        event = EventRecord.new({:event_definition => self, :item_id => item.id}) 
      end
    end
    event.timestamp = (self.timestamp_field.nil? ? Time.now : item.send(self.timestamp_field) )
    if !info_fields.nil? && !info_fields.empty?
      event.info = {}
      info_fields.split(',').each {|field| event.info[field] = item.send(field) }
    end
    #FIXME: if audits and relationship between audits and events are required, surely there may be a better way to do it in a DRY way... 
    event.audit = item.audits.last if ( item.respond_to?('audits') && item.audits.last && self.watched_actions.include?(item.audits.last.action) && (Time.now.tv_sec - item.audits.last.created_at.tv_sec < 10) )
    event if event.save
  end

  def triggers_event?(item)
    all_conditions = self.trigger_conditions || {}   

    item_conditions = all_conditions[:item] || {} 
    item_and_conditions = item_conditions[:and] || {}
    item_or_conditions = item_conditions[:or] || {}

    change_conditions = all_conditions[:change] || {} 
    change_and_conditions = change_conditions[:and] || {}
    change_or_conditions = change_conditions[:or] || {}

    check_item_and_conditions(item, item_and_conditions) && check_item_or_conditions(item, item_or_conditions) && check_change_and_conditions(item, change_and_conditions) && check_change_or_conditions(item, change_or_conditions)
  end

  def check_item_and_conditions(item,conditions)

    return true if conditions.empty?

    conditions.each do |key,value|
      return false if !(value.to_s.empty? || item.send(key) == value)
    end
    true
  end

  def check_item_or_conditions(item,conditions)

    return true if conditions.empty?

    conditions.each do |key,value|
      return true if (value.to_s.empty? || item.send(key) == value)
    end
    false
  end

  def check_change_and_conditions(item,conditions)

    return true if conditions.empty?

    conditions.each do |key,value|
      return false if !(item.changes.has_key?(key.to_s) && !item.changes[key.to_s].nil? && (value.to_s.empty? || item.changes[key.to_s].last == value))
    end
    true
  end

  def check_change_or_conditions(item,conditions)

    return true if conditions.empty?

    conditions.each do |key,value|
      return true if (item.changes.has_key?(key.to_s) && !item.changes[key.to_s].nil? && (value.to_s.empty? || item.changes[key.to_s].last == value))
    end
    false
  end

end
