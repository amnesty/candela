class HrSchoolLevel < ActiveRecord::Base

  attr_accessible :name

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::MultipleJoinsConditionForHrSchool

  validates_uniqueness_of :name

  has_and_belongs_to_many :hr_schools
  
end
