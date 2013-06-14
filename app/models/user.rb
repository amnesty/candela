# encoding: utf-8

#FIXME: REMOVE WHEN STATION INITALIZATION WORKS! This should be in ActiveSupport.on_load(:active_record) , but doesn't work....
ActiveRecord::Base.extend ActiveRecord::ActsAs

class User < ActiveRecord::Base
  
  attr_accessor :permissions_cache
  

  acts_as_agent :activation => false,
                :invite => false,
                :authentication => [ :login_and_password ]
  
  include ActiveRecord::AIActiveRecord

  has_many :performances, :foreign_key => 'agent_id', :dependent => :destroy
  has_many :organizations_trackings, :dependent => :destroy
  
  alias_attribute :name, :login
    
  scope :orderby_name, { :order => 'login ASC' }
  scope :include_in,   { :include => { :performances => [ :role ] }}

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
    
    match_permissions = []
    permissions.each do |permission|
      # Match by objective
      if permission[:action] == action.to_s and permission[:objective] == objective.to_s.camelize.singularize
        match_permissions << permission
      # Match by self
      elsif permission[:action] == action.to_s and permission[:objective].nil? and permission[:stage_type] == objective.to_s.camelize.singularize
        match_permissions << permission
      end
    end
    
    
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
    
      
      
    
    
  
end
