module ActiveRecord
  
  module AIOrganization
    class << self
      
      def included(base)
        base.class_eval do
          
          base.extend ClassMethods
        
          # COMMON VALIDATES
            # Formatting of email fields
            validates_format_of :email,   :with => ActiveRecord::Base::REGEXP_EMAIL, :on => :save, :allow_blank => true
            validates_format_of :email_2, :with => ActiveRecord::Base::REGEXP_EMAIL, :on => :save, :allow_blank => true
            
            # Uniquess
            validates_uniqueness_of :name
            
            # Presence
            validates_presence_of :phone, :address, :cp, :province_id, :city, :email
    
            # Numericality
            validates_numericality_of :phone, :cp, :fax, :postal_cp, :delivery_cp, :delivery_phone, :on => :save, :allow_blank => true
            
    
            # Length of
            validates_length_of :phone,          :is => 9, :allow_blank => false
            validates_length_of :delivery_phone, :is => 9, :allow_blank => true
            validates_length_of :cp,             :is => 5, :allow_blank => false
            validates_length_of :fax,            :is => 9, :allow_blank => true
            validates_length_of :postal_cp,      :is => 5, :allow_blank => true
            validates_length_of :delivery_cp,    :is => 5, :allow_blank => true
            
            
          # CALLBACKS
            before_destroy :check_activists
            
          # RELATIONS
            # belongs to
            belongs_to :province
            belongs_to :postal_province,   :foreign_key => :postal_province_id,   :class_name => "Province"
            belongs_to :delivery_province, :foreign_key => :delivery_province_id, :class_name => "Province"
            
            # has_many
            has_many :notes,                    :dependent => :destroy, :as => 'noteable'
            has_many :activists_collaborations, :dependent => :destroy, :as => :organization
            has_many :organization_on_offs,     :dependent => :destroy, :as => :organization
            has_many :organizations_trackings,  :dependent => :destroy, :as => :organization
            
          # ACTS AS
            acts_as_container
            acts_as_stage :admissions => false
            
          # Named Scope's
            # FIXME, sure we can do it by authorization blocks
            scope :can_choose, lambda { |agent|
              conditions = "#{ self.name.tableize }.enabled = 1"
              if agent.is_a?(User) and not agent.has_any_permission_to(:read, self.name, :on => Site.current)
                can_read = agent.performances.select{|p|  p.stage_type == "#{ self.name }" }.map(&:stage_id) 
                if can_read.any?
                  conditions = '' "#{ self.name.tableize }.id IN(#{ can_read.join(',') })"
                else # ensure cant read
                  conditions = " 1 != 1 "
                end
              end 
 
              {  :conditions => "#{ conditions }" }
            }
            scope :only_collaborations_enabled, { :conditions => [ 'collaborations_enabled = true' ] }
            
            base.class_eval do
              # Organization default authorization if user include permission in stage
              authorizing do |user, permission|
                ret = nil
                if user.is_a?(User)
                  ret = user.has_any_permission_to(permission, self.class, :on => self) || nil
                end
                ret
              end
            end
          
          # Include instance methods
            base.send :include, InstanceMethods
        end
      end
      
      def 
      
      
      # OMG what it is???? FIXME
      def validate
        r = Gx.validate_address( self.cp, self.province_id, self.city )
        if not r[0]
          self.errors.add :base, r[1]
        end
        r = Gx.validate_address( self.postal_cp, self.postal_province_id, self.postal_city )
        if not r[0]
          self.errors.add :base, r[1]
        end
        r = Gx.validate_address( self.delivery_cp, self.delivery_province_id, self.delivery_city )
        if not r[0]
          self.errors.add :base, r[1]
        end
      end
      
      module InstanceMethods
        def check_activists
          if self.activists_collaborations.any?
            self.errors.add :base, :has_activists
            return false
          end
        end
        def same_address_for_deliver_and_postal?
          self.postal_cp.eql?(self.delivery_cp) and self.postal_city.eql?(self.delivery_city) and self.postal_province_id.eql?(self.delivery_province_id)
        end

        def email_addresses
          ret = []
          ret << email if email?
          ret << email_2 if email_2?
          ret
        end
        
      end
      module ClassMethods
        def default_order_field
          "#{ self.name.tableize }.name"
        end

        def searcheable_fields
          [unhideable_fields, hideable_fields].flatten
        end

        def unhideable_fields
          [ "enabled", "name", "collaborations_enabled", "phone", "address", "cp", "province_id", "city", "email"]
        end

        def hideable_fields
          [ 
            "email_2", "fax", "customer_service_time", 
            "/meetings", "meeting_weekday", "meeting_frequency", "meeting_hours", "meeting_venue", 
            "/postal_address", "postal_address", "postal_cp", "postal_province_id", "postal_city",
            "/delivery_address", "delivery_contact", "delivery_phone", "delivery_hours", "delivery_address", "delivery_cp", "delivery_province_id", "delivery_city"            
          ]
        end

        def conditions_columns 
          { :cont   => [ "name", "address", "city", "email", "cp", "customer_service_time", 
                          "delivery_address", "delivery_city", "delivery_contact", "delivery_cp", "delivery_hours", "delivery_phone", 
                          "email_2", "fax", "meeting_frequency", "meeting_hours", "meeting_venue", "meeting_weekday", "phone", 
                          "postal_address", "postal_city", "postal_cp"
                       ],
            :eq => ['enabled', "collaborations_enabled", "province_id", "delivery_province_id", "postal_province_id"
                       ],
            :date   => [ 'created_at', 'updated_at' ] }
        end

        def condition_type_for_column(column_name)
          ret = ''
          conditions_columns.each_pair do |key,value|
            ret = key if value.include?(column_name)
          end
          ret
        end

        def sort_for_csv(items)
          items
        end

      end
    end
  end
end


        
#         
# 
#   acts_as_stage :admissions => false
# 
#   belongs_to :province
#   belongs_to :postal_province, :foreign_key => :postal_province_id, :class_name => "Province"
#   belongs_to :delivery_province, :foreign_key => :delivery_province_id, :class_name => "Province"
# 
#   validates_uniqueness_of :name
#   validates_presence_of :phone, :address, :cp, :province_id, :city, :email
#   validates_numericality_of :cp, :fax, :postal_cp, :delivery_cp, :delivery_phone, :on => :save, :allow_blank => true
#   validates_length_of :cp, :is => 5, :allow_blank => false
#   validates_length_of :fax, :is => 9, :allow_blank => true
#   validates_length_of :postal_cp, :is => 5, :allow_blank => true
#   validates_length_of :delivery_cp, :is => 5, :allow_blank => true
#   REGEXP_EMAIL = 
#   validates_format_of :email, :with => REGEXP_EMAIL, :on => :save, :allow_blank => true
#   validates_format_of :email_2, :with => REGEXP_EMAIL, :on => :save, :allow_blank => true
# 
#   
#   
#         
#         base.column_names rescue return                                           # The table might not yet exist
#         base.validates_presence_of :name if base.column_names.include?('name')    # Name is always needed if exists
#         #FIXME: This will be not needed when there is a sort_column attribute
#         base.scope :orderby_name, lambda {
#           base.column_names.include?('name') ?
#             { :order => 'name ASC' } : {}
#         }
#         base.scope :enabled, lambda {
#           base.column_names.include?('enabled') ?
#             { :conditions => [ 'enabled = true' ] } : {}
#         }
#         base.scope :can_see, lambda { |agent| {} }
#         
#         base.scope :limited, lambda { |*num|
#           { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
#         }
#         
#         base.scope :last_ones, { :order => 'updated_at DESC'}                 # last_ones ordered
#         
#         base.acts_as_resource                                                       # modes as resources
#         base.class_eval do
#           # Global authrozing permissions
#           authorizing do |user, permission|
#             Site.current.authorize?( [permission, base.name.to_sym], :to => user, :default => nil)
#           end
#         end
#           
# 
#       end
