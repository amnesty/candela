class ActivistStatusChange < EventRecord
  
  belongs_to :activist_status
  belongs_to :activist
  belongs_to :activists_collaboration

  # FIXME: Overriding model_name is a fast alternative to avoid duplicating partials for a STI subclass. Find a better way!!
  def self.model_name
    EventRecord.model_name
  end

  def activist
    event_object.activist
  end

  def activists_collaboration
    event_object
  end

  def activist_status_id
    info["activist_status_id"]
  end

  def activist_status
    ActivistStatus.find(activist_status_id)
  end

  def date 
    timestamp
  end

  def self.from_activists_collaboration (collaboration)
    self.with_codename('activists_collaboration_status_changed').for_object(collaboration).all
  end

#---------------------------------
# Overridden EventRecord methods
#---------------------------------

  def h_extra_info
    I18n.t 'activist_status_change.texts.full_description', 
      :date => I18n.localize(date.to_date), 
      :activist_name => activist.full_name,
      :status_change_name => activist_status.name, 
      :collaboration_type => activists_collaboration.kind, 
      :organization => activists_collaboration.organization_name
  end

#FIXME: Fix permissions for EventRecord child classes!!!! 
  def authorize? (user,permission)
    self.dup.becomes(EventRecord).authorize?(user,permission)
  end

end
