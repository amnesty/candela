class AcademicYear < ActiveRecord::Base
  
  include ActiveRecord::MultipleJoinsConditionForHrSchool

  attr_accessible :year

  validates_uniqueness_of :year
  has_and_belongs_to_many :hr_schools
  
  def name; year; end

end
