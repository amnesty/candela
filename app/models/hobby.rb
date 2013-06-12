class Hobby < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::MultipleJoinsConditionForActivist

  validates_uniqueness_of :name

  def self.blogger
    Hobby.find(:first, :conditions => "name = 'Blogger'" )
  end



end
