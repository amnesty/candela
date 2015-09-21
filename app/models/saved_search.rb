 class SavedSearch < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord

  attr_accessible :name, :target, :params, :user

  belongs_to :user

  serialize :params, Hash

  validates_presence_of :name, :user, :target

  scope :for_target, lambda { |target| {:conditions => {:target => target} } } 

  def to_title
    name
  end  
  
  def self.default_order_field
    'target'
  end
  
#---------------------------
# Permissions
#---------------------------

  scope :can_see, lambda{ |agent|
    { :conditions => {:user_id => agent.id} }
  }

  # All actions allowed for owner
  authorizing do |user, permission|
    if user.is_a?(User)
      return true if self.user == user 
    end
    nil 
  end
  
end
