class CustomAction < PerformedAction

  validates_presence_of :custom_name

  def to_title
    "#{ organization.to_title }/#{ custom_name }"
  end
  
  def authorize? (user,permission)
    self.dup.becomes(PerformedAction).authorize?(user,permission)
  end

  def self.unhideable_fields
    [ 'custom_name','custom_action_topics']
  end

end
