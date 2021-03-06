class Language < ActiveRecord::Base
  
  attr_accessible :name

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::MultipleJoinsConditionForActivist

  validates_uniqueness_of :name

  has_and_belongs_to_many :activists


end

