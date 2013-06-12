module ActiveRecord
  
  module AIActivist
    class << self
      
      def included(base)
        
        base.class_eval do
          
          base.extend ClassMethods

          # COMMON VALIDATES
            # Formatting of email fields
            validates_format_of :email,   :with => ActiveRecord::Base::REGEXP_EMAIL, :on => :save, :allow_blank => true
            validates_format_of :nif,     :with => ActiveRecord::Base::REGEXP_NIF, :if => Proc.new{|a| a.document_type == 'NIF' }, :message => Gx.t_error('activist.nif.invalid'), :allow_blank => true
            
            # Uniquess
            validates_uniqueness_of :email, :allow_nil => true, :allow_blank => true
            validates_uniqueness_of :first_name, :scope => [ :last_name, :last_name2 ]
            
            # Presence
            validates_presence_of :first_name, :last_name, :phone, :birth_day
            
            # Numericality
            validates_numericality_of :phone,        :on => :save, :allow_blank => false
            validates_numericality_of :mobile_phone, :on => :save, :allow_blank => true
            
             # Length of
            validates_length_of :phone,        :is => 9, :allow_blank => false
            validates_length_of :mobile_phone, :is => 9, :allow_blank => true
            validates_length_of :nif,          :in => 6..9, :allow_blank => true, :if => Proc.new{|a| a.document_type == 'NIF' }, :message => Gx.t_error('activist.nif.invalid_length')
	    
            # Others
            validate :birth_day_not_in_future
            validate :valid_nif_letter
            validate :valid_nie_letter
            
          # CALLBACKS
            after_destroy :clear_hbtm
            
          # RELATIONS
            # belongs to
            belongs_to :occupation
            belongs_to :sex
            belongs_to :province
            belongs_to :labour_situation
            belongs_to :student_level
            belongs_to :student_year
            belongs_to :informed_through
  
            # has_and_belongs_to_many
            has_and_belongs_to_many :languages
            has_and_belongs_to_many :hobbies
            has_and_belongs_to_many :skills
            has_and_belongs_to_many :talks
            has_and_belongs_to_many :collabtopics

                        

          # ACTS AS
            acts_as_container
            
          # Named Scope's
            scope :orderby_name, { :order => 'last_name ASC, last_name2 ASC, first_name ASC' }
  
            
   
          end
          
          base.send :include, InstanceMethods
          
      end
       
      module InstanceMethods

        def full_name
          "#{ self.first_name } #{ self.last_name } #{ self.last_name2 }"
        end

        def second_first_name
          result = self.last_name
          if self.last_name2 != ""
            result = result + " " + self.last_name2
          end
          result + ", " + self.first_name
        end
        
        private
        def clear_hbtm
          languages.destroy_all
          hobbies.destroy_all
          skills.destroy_all
          talks.destroy_all
          collabtopics.destroy_all
        end
        def birth_day_not_in_future      
          if self.birth_day and self.birth_day > Date.today
            self.errors.add :base, :birth_day_future
          end
        end
	
        def valid_nif_letter
	      if nif.present? and document_type == 'NIF' and self.class.calculate_nif_letter(nif) != nif[-1..-1].upcase
	        self.errors.add(:nif, Gx.t_error('activist.nif.invalid_letter', :letter => self.class.calculate_nif_letter(nif))) 
	      end
	    end
	
	    def valid_nie_letter
	      if nif.present? and document_type == 'NIE'
            if !"XYZ".include?(nif.first.upcase)
	          self.errors.add(:nif, :nie_must_start_xyz) 
            elsif self.class.calculate_nie_letter(nif) != nif[-1..-1].upcase 
              self.errors.add(:nif, Gx.t_error('activist.nif.invalid_letter', :letter => self.class.calculate_nie_letter(nif))) 
            end
	      end
	    end

      end

      module ClassMethods
        def default_order_field
          "#{ self.name.tableize }.last_name, #{ self.name.tableize }.last_name2"
        end

	      def calculate_nie_letter( _nie )
          str = ""
          case _nie.first.upcase
            when "X"
              str = _nie[1..-1]
            when "Y"
              str = "1#{_nie[1..-1]}"
            when "Z"
              str = "2#{_nie[1..-1]}"
          end
          calculate_nif_letter(str) if !str.empty?
        end

	      def calculate_nif_letter( _nif )
          "TRWAGMYFPDXBNJZSQVHLCKE"[_nif.to_i % 23].chr
        end

def test_nif_data
  nifs = self.all.collect{|a| a if a.document_type == "NIF"}.compact          
  nies = self.all.collect{|a| a if a.document_type == "NIE"}.compact          
  otros = self.all.collect{|a| a if a.document_type == "Otros"}.compact          

  nifs_bad_letter = nifs.collect{|a| a.nif if self.calculate_nif_letter(a.nif) != a.nif.last}.compact
  nies_bad_letter = nies.collect{|a| a.nif if self.calculate_nie_letter(a.nif) != a.nif.last}.compact
  puts "NIF: #{nifs.count} total, #{nifs_bad_letter.count} with bad letter."
  puts "NIE: #{nies.count} total, #{nies_bad_letter.count} with bad letter."
  puts "OTHER: #{otros.count} total."
  {:nifs_bad_letter => nifs_bad_letter, :nies_bad_letter => nies_bad_letter}
end
      end
    end
  end        
end
            
  
  
