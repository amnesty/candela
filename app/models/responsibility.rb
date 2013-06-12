
class Responsibility < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord

  scope :for_member, { :conditions => 'for_member=true' }
  scope :for_autonomy, { :conditions => 'for_autonomy=true' }

  scope :by_ids, lambda { |ids| 
    ret = {}
    unless ids.nil? || ids.empty?
      ids.is_a?(Hash) ? ids = ids.keys : nil
      responsibilities_ids_str = ids.collect{|i| "'#{i}'"}.join(',')
      ret = {:conditions => "responsibilities.id IN (#{responsibilities_ids_str})"}
    end
    ret
  }

#  scope :by_ids, lambda { |ids|
#    ret = {}
#    unless ids.nil?
#	ret                 = { :joins => '', :conditions => [] }
#	count               = 0
#	relation_table_name = "activists_collaborations_responsibilities"
#	object_r_table_name = "responsibilities"

#	ids.keys.each { |relation_id|
#	  
#	  ret[:joins]      << "INNER JOIN `#{ relation_table_name }` AS `#{ relation_table_name }_#{ count }` \
#ON `#{ relation_table_name }_#{ count }`.activists_collaboration_id = activists_collaborations.id          \
#INNER JOIN `#{ object_r_table_name }` AS `#{object_r_table_name }_#{ count }`  \
#ON `#{ object_r_table_name }_#{ count }`.id = `#{ relation_table_name }_#{ count }`.#{ object_r_table_name.singularize }_id " 
#	  ret[:conditions] << "#{ object_r_table_name }_#{ count }.id = #{ relation_id }"
#	  count += 1
#	}
#	ret[:conditions] = ret[:conditions].join(' AND ')                              

#    end
#    ret
#  }
  
  validates_uniqueness_of :name

end
