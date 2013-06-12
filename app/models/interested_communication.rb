class InterestedCommunication < EventRecord
  
  belongs_to :interested

  before_create :add_changed_field

  def add_changed_field

#logger.info "*********** CHANGES: #{event_object.changes.inspect}"
#    info[:changes_on] = []
#    event_object.changes.each do |key,value|
#      info[:changes_on] = info[:changes_on].push(key) if info_fields.include? key.to_s
#    end
  end

  def event_codename
    'interested_communication'
  end

  def interested
    event_object
  end

  def self.from_interested(interested)
    self.with_codename(event_codename).for_object(interested).all
  end

  def communication_description
    watched_fields = event_definition.trigger_conditions[:change][:or].keys
    communication_fields = info["changes"].collect{|key,value| Gx.t_attr("interested.#{key}") if watched_fields.include? key.to_sym}.compact
    communication_fields.join(', ')
  end
#---------------------------------
# Overridden EventRecord methods
#---------------------------------

  def self.extra_trigger_check(item)
  end

  def self.extra_before_create(item)
  end

  def h_extra_info
    info.each { |key,value| Gx.t_attr "interested.#{key}"}.join(', ')
  end

#FIXME: Fix permissions for EventRecord child classes!!!! 
  def authorize? (user,permission)
    self.becomes(EventRecord).authorize?(user,permission)
  end


end
