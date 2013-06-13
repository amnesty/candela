class InterestedsTalk < ActiveRecord::Base

  attr_accessible :attended

  belongs_to :interested
  belongs_to :talk
  
  scope :interesteds_in_talk, lambda { |talk| 
    {
      :conditions => [ "talk_id = ?", talk.id]
    }
  }

end
