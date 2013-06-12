class InterestedsTalk < ActiveRecord::Base
  
  scope :interesteds_in_talk, lambda { |talk| 
    {
      :conditions => [ "talk_id = ?", talk.id]
    }
  }
  
end
