class Province < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord


  has_one :activists
  has_many :cities

  validates_uniqueness_of :name, :scope => :country_id

  def self.madrid_id
    find(:first, :conditions => "name = 'Madrid'").id
  end

end

