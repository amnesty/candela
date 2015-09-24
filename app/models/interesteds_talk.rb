class InterestedsTalk < ActiveRecord::Base

  attr_accessible :attended

  belongs_to :interested
  belongs_to :talk
  
  scope :interesteds_in_talk, lambda { |talk| 
    {
      :conditions => [ "talk_id = ?", talk.id]
    }
  }
  
  def status
    return :pending if talk.is_in_future?
    attended ? :attended : :not_attended    
  end

  def h_status
    I18n.t("interested.talk_attendance_status.#{status.to_s}")
  end
  
end
