module ActiveRecord
  
  class Base
    REGEXP_NIF          = /^[0-9]*[a-zA-Z0-9]$/               unless defined? REGEXP_NIF
    REGEXP_EMAIL        = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i  unless defined? REGEXP_EMAIL
    REGEXP_ONLY_ALPHA   = /^[^0-9]*$/                                    unless defined? REGEXP_ONLY_ALPHA
    REGEXP_ET_NUMBER    = /^E-[0-9]+$/                                   unless defined? REGEXP_ET_NUMBER
    REGEXP_ONLY_NUMERIC = /^[0-9 \-]*$/                                  unless defined? REGEXP_ONLY_NUMERIC
  end
  

  module AIActiveRecord

    class << self

      def included(base) # :nodoc:
        
        base.extend ClassMethods
        
        base.column_names rescue return                                           # The table might not yet exist
        base.validates_presence_of :name if base.column_names.include?('name')    # Name is always needed if exists
        
        # FIXME: This will be not needed when there is a sort_column attribute
        base.scope :orderby_name, lambda {
          base.column_names.include?('name') ?
            { :order => 'name ASC' } : {}
        }
        base.scope :enabled, lambda {
          base.column_names.include?('enabled') ?
            { :conditions => [ 'enabled = true' ] } : {}
        }
        base.scope :can_see, lambda { |agent| {} }
        
        
        
        base.scope :include_in, {}
        
        base.scope :container_is, lambda { |container|  }
        
        base.scope :limited, lambda { |*num|
          { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
        }
        
        base.scope :last_ones, { :order => 'updated_at DESC'}                 # last_ones ordered
        
        base.acts_as_resource                                                       # modes as resources

        base.class_eval do

          include ActiveRecord::Authorization
          
          # Global authrozing permissions
          authorizing do |user, permission|
            Site.current.authorize?( [permission, base.name.to_sym], :to => user, :default => nil)
            # user.has_any_permission_to(permission, base.name.to_sym, :on => Site.current ) || nil
          end
          
          # Permission access to index. If is new_record and permission is read, just check user has_any_permission_to
          authorizing do |user, permission|
            ret = nil
            if new_record? and permission == :read
              options = {}
              if @container
                options[:on] = @container
              end
              
              ret = (user.is_a?(User) and user.has_any_permission_to(:read, base.name, options) || nil)
            end
            ret
          end
        end
        
      end
      
      
      module ClassMethods
        
        # Parse Model entries to testing fixture yaml format, like
        # $> Country.all                        
        #                 # <Country, id: => 1, isoname: "es" >
        # $> Country.to_testing_fixture_format
        #                 # Create file at spec/fixtures/countries.yml with data
        #                 country_1:
        #                   id: 1
        #                   isoname: es
        #
        # We will use it to perform test against same production database
        def to_testing_fixture_format
        
          klass_name = self.name
          file_name  = klass_name.underscore.pluralize
          
          objects       = self.all
          objects_hash  = {}
          count         = 1
          objects.each do |object|
            objects_hash["#{ klass_name.underscore }_#{ count }".to_sym] = object.attributes
            count += 1
          end
          
          
          # write file
          file_path = "#{ Rails.root }/spec/fixtures/#{ file_name }.yml"
        
          File.open(file_path, "w") do |f|
            count.times do |time|
              element = "#{ klass_name.underscore }_#{ time }"
              f.write({ element => objects_hash[element.to_sym] }.to_yaml)
            end
          end
        end

#        def default_order_field
#          column_names.include?("updated_at") && "#{ table_name }.updated_at" || [ table_name, columns.first.name ].join('.')
#        end

#        def default_order_direction
#          column_names.include?("updated_at") && "ASC" || "DESC"
#        end
    
        def has_fast_search?
          true
        end

        #TODO: Use ransack also for sorting -> parameters || class_defaults || updated_at.desc || id.asc
        def advanced_search(parameters, agent)
#          ransack_with_scopes(parameters[self.name.underscore.to_sym]).result(:distinct => true).can_see(agent).include_in.order("#{self.default_order_field if self.respond_to?("default_order_field")} #{self.default_order_direction if self.respond_to?("default_order_direction")}")
          search = self.can_see(agent).include_in.ransack_with_scopes(parameters[self.name.underscore.to_sym])
#          search.sorts ||= "#{self.default_order_field if self.respond_to?("default_order_field")} #{self.default_order_direction if self.respond_to?("default_order_direction")}"
          search.result(:distinct => true).order("#{self.default_order_field if self.respond_to?("default_order_field")} #{self.default_order_direction if self.respond_to?("default_order_direction")}")
        end                                       

      end      
    end
  end  
end

