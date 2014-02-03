class Campaign < ActiveRecord::Base

  attr_accessible :name, :campaigntopic_id, :country_id, :starting_at, :ending_at

  include ActiveRecord::AIActiveRecord

  validates_uniqueness_of :name
  
  belongs_to :campaigntopic
  belongs_to :country

  
  has_many :campaignactions
  
  validate :conflicting_dates
  validates_presence_of :starting_at, :ending_at, :country_id, :campaigntopic_id
  
  def to_title
    name
  end
  
  def self.default_order_field
    "campaigns.starting_at"
  end
  
  def self.default_order_direction
    "DESC"
  end

  # only to read permission
  authorizing do |user, permission|
    (user.is_a?(User) and permission == :read and user.has_any_permission_to(permission, :campaign)) || nil
  end
  
  
  private
  def conflicting_dates
    if starting_at.present? and ending_at.present? and starting_at > ending_at
      self.errors.add :base, :conflicting_dates
    end
  end
  
end


