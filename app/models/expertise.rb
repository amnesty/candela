#<<<<<MODULE_INFO
# Type Model
#>>>>>MODULE_INFO
#<<<<<MODULE_DEFINITION
class Expertise < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord
#>>>>>MODULE_DEFINITION

  validates_uniqueness_of :name

  scope :by_ids, lambda { |ids| 
    ret = {}
    unless ids.nil? || ids.empty?
      ids.is_a?(Hash) ? ids = ids.keys : nil
      expertises_ids_str = ids.collect{|i| "'#{i}'"}.join(',')
      ret = {:conditions => "expertises.id IN (#{expertises_ids_str})"}
    end
    ret
  }

end
