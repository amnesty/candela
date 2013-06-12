#<<<<<MODULE_INFO
# Type Model
#>>>>>MODULE_INFO

#<<<<<MODULE_DEFINITION
class Campaigntopic < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord
#>>>>>MODULE_DEFINITION
  validates_uniqueness_of :name

end
