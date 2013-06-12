class Sex < ActiveRecord::Base

  validates_uniqueness_of :name

  def self.female
    1
  end

  def self.male
    2
  end

end
