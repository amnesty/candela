module ActiveRecord
  
  module MultipleJoinsConditionForActivist
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
#                relation_table_name = "activists_#{ base.base_class.table_name }"
#                object_r_table_name = "#{ base.base_class.table_name }"
#                ids.keys.each { |relation_id|
#                  
#                  ret[:joins]      << "INNER JOIN `#{ relation_table_name }` AS `#{ relation_table_name }_#{ count }` \
#ON `#{ relation_table_name }_#{ count }`.activist_id = `activists`.id          \
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
