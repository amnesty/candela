class Availability < ActiveRecord::Base

  validates_uniqueness_of :name
  has_many :activists_collaborations

end
