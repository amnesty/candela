
class Responsibility < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord

  attr_accessible :name

  has_and_belongs_to_many :activists_collaborations

  scope :by_ids, lambda { |ids| 
    ret = {}
    unless ids.nil? || ids.empty?
      ids.is_a?(Hash) ? ids = ids.keys : nil
      responsibilities_ids_str = ids.collect{|i| "'#{i}'"}.join(',')
      ret = {:conditions => "responsibilities.id IN (#{responsibilities_ids_str})"}
    end
    ret
  }
 
  validates_uniqueness_of :name

end
