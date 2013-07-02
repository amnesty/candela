class Campaignaction < PerformedAction

  validates_presence_of :campaign_id
  validates_uniqueness_of :campaign_id, :scope => [ :organization_id, :organization_type ], :message => I18n.t('activerecord.errors.models.campaignaction.duplicated_action')
  
  scope :include_in,  { :include => [ :campaign ] }
  

  def to_title
    "#{ organization.to_title }/#{ campaign.name }"
  end
  
  def authorize? (user,permission)
    self.dup.becomes(PerformedAction).authorize?(user,permission)
  end

  def self.unhideable_fields
    [ "campaign_id"]
  end

end
