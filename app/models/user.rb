# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :omniauthable
  # :registerable, :recoverable, :rememberable, 
  devise :database_authenticatable, :validatable, :trackable, :timeoutable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :login, :email, :password, :password_confirmation, :remember_me
  attr_accessible #:login, :email, :password, :password_confirmation, :remember_me

#-----------------------------------------------------
# METHODS FROM OLD USERS (CHECK)

  attr_accessor :permissions_cache

  include ActiveRecord::AIActiveRecord
  
  acts_as_agent

  has_many :performances, :foreign_key => 'agent_id', :dependent => :destroy
  has_many :organizations_trackings, :dependent => :destroy
  has_many :saved_searches, :dependent => :destroy
  
  alias_attribute :name, :login
    
  scope :orderby_name, { :order => 'login ASC' }
  scope :include_in,   { :include => { :performances => [ :role ] }}

  def related_organizations
    performances.collect do |p| 
      if p.stage.is_a? ActiveRecord::AIOrganization
        p.stage
      elsif p.stage.is_a? AutonomicTeam
        p.autonomy
      end 
    end.compact.uniq
  end
  
  def update_performances(attrs, performance_object)
    
    unless attrs.present? and attrs[:role_id].present? and attrs[:stage_type].present? and attrs[:stage_ids].present? and attrs[:stage_ids].any? 
      performance_object.errors.add :base, :not_valid
      return false
    end
    
    # Destroy all performances of Stage Type
    performances = []
    
    attrs[:stage_ids].each do |stage_id|
      performances << self.performances.build(:agent_id   => self.id,
                                              :agent_type => 'User',
                                              :stage_type => attrs[:stage_type],
                                              :stage_id   => stage_id,
                                              :role_id    => attrs[:role_id])
    end
    
    self.save
  end

  def self.fast_search_fields
    ['users.login', 'users.email' ]
  end
  
  def to_title
    name
  end
  
  def full_name
    name
  end
  
  def has_any_permission_to(action, objective, options = {})

    objective_class_name = objective.to_s.camelize.singularize
    match_permissions = permissions.select{|p| p[:action] == action.to_s and 
                                               (p[:objective] == objective_class_name or 
                                               (p[:objective].nil? and p[:stage_type] == objective_class_name))}

    if options[:on]
      # scope on, or Site global permission
      match_permissions = match_permissions.select{ |p| (p[:stage_type] == options[:on].class.name and p[:stage_id] == options[:on].id) or p[:stage_type] == 'Site' }
    end
    
    match_permissions.any?
  end
  
  def permissions
    @permissions_cache || eval_permissions
  end
  
  def eval_permissions
    permissions_array = []
    self.agent_performances.each do |p|
      p.role.permissions.each do |pm|
        permissions_array << { :stage_type => p.stage_type, :stage_id => p.stage_id, :objective => pm.objective, :action => pm.action }
      end
    end
    @permissions_cache = permissions_array
  end
  
  
  def print_permissions
    
    performaces = self.performances
    string      = "User #{ self.name } has #{ performaces.count } performances:"
    
    puts "\n#{ string }\n"
    puts "#{ '-' * string.length }\n"
    
    performaces.each do |performance|
      string = "Performance in stage `#{ performance.stage.full_name } (#{ performance.stage_type }##{ performance.stage_id}`. Role `#{ performance.role.name } (Role##{ performance.role_id })`"
           
      puts "\n » #{ string }\n"
      puts " --#{ '-' * string.length }\n"
      
      performance_permissions_objectives = performance.role.permissions.sort { |a,b| a.objective.to_s <=> b.objective.to_s }.map(&:objective).uniq
      
      performance_permissions_objectives.each do |objective|
        
        objective_permissions = performance.role.permissions.select { |perm| perm.objective == objective }
        
        puts "    * Over `#{ objective.nil? ? 'self' : objective }` can #{ objective_permissions.map(&:action).join(', ') }"
      end
    end
    
    puts "\n\n Also user can track nexts organizations\n"
    
    if organizations_trackings.any?
      organizations_trackings.each do |organization_tracking|
        puts "   » #{ organization_tracking.organization.full_name }"
      end
    else
      puts "   NONE"
    end
     
  end
  
  def check_authorization_chain_for(object, permission)
    
    klass = object.class
    
    object.class.authorization_chain.each do |proc_chain|
      result = proc_chain.bind(object).call(self, permission)
      puts "chain #{ proc_chain } gives #{ result.inspect }"
    end
    
  end
  
  def can_track?(organization)
    organizations_trackings.map(&:organization).include?(organization)
  end

#------------------------------------------------------------------
# Legacy users password management

  def valid_password?(password_str)
    begin
      super(password_str) || legacy_user_valid_password?(password_str)
    rescue BCrypt::Errors::InvalidHash
      legacy_user_valid_password?(password_str)
    end
  end

  def self.update_legacy_passwords_from_yaml(filename)
    usr_info = YAML.load_file(filename)
    usr_info.each do |usr_login,usr_password| 
      u = User.find_by_login(usr_login)
      if u 
        if u.valid_password?(usr_password)
          puts "User #{u.login} updated." 
        else
          puts "User #{u.login} not updated: wrong password!!" 
        end
      else
        puts "[WARNING] User #{usr_login} does not exist!!"
      end        
    end
  end

private

  def legacy_user_valid_password?(password_str)
    return false unless OldUser.find(self.id).valid_password?(password_str)
    logger.info "[DEVISE legacy users] - User #{login} is using the old password hashing method, updating attribute."
    self.update_attributes :password => password_str, :password_confirmation => password_str
    true
  end

end
