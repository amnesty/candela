class HrWorkThrough < ActiveRecord::Base

  include ActiveRecord::MultipleJoinsConditionForHrSchool

    
  scope :orderby_name, { :order => 'name ASC'}

  validates_uniqueness_of :name

  def full_name
    name
  end

  # for searches
  has_and_belongs_to_many :hr_schools

end
