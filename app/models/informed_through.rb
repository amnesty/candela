class InformedThrough < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord

  attr_accessible :name

  validates_uniqueness_of :name
  
  def self.web
    find(5)
  end

end



