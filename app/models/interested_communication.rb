class InterestedCommunication < EventRecord
  
  belongs_to :interested

  before_validation :set_communication_description

  validates_presence_of :timestamp
  validate :can_build_communication_description?

  attr_accessor :communication_description
  
  after_initialize do |communication|
    communication.event_definition = EventDefinition.find_by_klass('InterestedCommunication') if !communication.event_definition
  end

  def mass_assignment_authorizer(role = nil)
    super + ([:timestamp, :communication_description])
  end

  def set_communication_description
    info['communication_description'] = @communication_description if @communication_description
  end

  def has_fast_search?
    false
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
    if self.new_record?
      ''
    elsif !info['communication_description'].blank?
      info['communication_description']
    elsif info['changes']
      watched_fields = event_definition.trigger_conditions[:change][:or].keys
      communication_fields = info["changes"].collect{|key,value| Gx.t_attr("interested.#{key}") if watched_fields.include? key.to_sym}.compact
      communication_fields.join(', ')
    else
      ""
    end
  end

  def can_build_communication_description?
    errors.add :communication_description, I18n.t("errors.messages.blank") if (info['communication_description'].blank? && info['changes'].blank?)
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
    self.dup.becomes(EventRecord).authorize?(user,permission)
  end


end
