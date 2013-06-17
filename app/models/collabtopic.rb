class Collabtopic < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord
  include ActiveRecord::MultipleJoinsConditionForActivist

  attr_accessible :name

  validates_uniqueness_of :name
  has_and_belongs_to_many :activists

end



