class HowKnow < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord

  attr_accessible :name

  validates_uniqueness_of :name
  
end



