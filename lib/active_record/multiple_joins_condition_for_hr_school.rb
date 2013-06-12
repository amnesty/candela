module ActiveRecord
  
  module MultipleJoinsConditionForHrSchool
    class << self  
      def included(base)
        
        base.class_eval do

          base.scope :by_ids, lambda { |ids| 
            ret = {}
            unless ids.nil? || ids.empty?
              ids.is_a?(Hash) ? ids = ids.keys : nil
              ids_str = ids.collect{|i| "'#{i}'"}.join(',')
              ret = {:conditions => "#{ base.base_class.table_name }.id IN (#{ids_str})"}
            end
            ret
          }
          
#          base.scope :by_ids, lambda { |ids|
#            ret = {}
#            unless ids.nil?
#                ret                 = { :joins => '', :conditions => [] }
#                count               = 0
#                                           
#                object_r_table_name = "#{ base.base_class.table_name }"
#                relation_table_name = "hr_schools" > object_r_table_name ? "#{ base.base_class.table_name }_hr_schools" : "hr_schools_#{ base.base_class.table_name }"
#                                           
#                ids.keys.each { |relation_id|
#                  
#                  ret[:joins]      << "INNER JOIN `#{ relation_table_name }` AS `#{ relation_table_name }_#{ count }` \
#ON `#{ relation_table_name }_#{ count }`.hr_school_id = `hr_schools`.id          \
#INNER JOIN `#{ object_r_table_name }` AS `#{object_r_table_name }_#{ count }`  \
#ON `#{ object_r_table_name }_#{ count }`.id = `#{ relation_table_name }_#{ count }`.#{ object_r_table_name.singularize }_id " 
#                  ret[:conditions] << "#{ object_r_table_name }_#{ count }.id = #{ relation_id }"
#                  count += 1
#                }
#                ret[:conditions] = ret[:conditions].join(' AND ')                              

#            end
#            ret
#          }
          
        end
      end
      
    end
  end
end
