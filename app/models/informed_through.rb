class InformedThrough < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord

  validates_uniqueness_of :name
  
  def self.web
    find(5)
  end

end



