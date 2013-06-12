class Note < ActiveRecord::Base
  
  attr_accessible :title, :body, :monitoring_person, :monitoring_topic, :monitoring_date, :parents

  # deep is not stored in database. dinamiclly constructed
  attr_accessor :deep
  @@replay_authorize = nil
  @@edit_authorize   = nil

  # Include common code for ActiveRecord
  include ActiveRecord::AIActiveRecord
  
  # Relations, scopes, callbacks, validate stuff
  before_destroy          :check_children_before_destroy
  
  belongs_to              :noteable, :polymorphic => true
  belongs_to              :author, :class_name => 'User', :foreign_key => :created_by
  
  validates_presence_of   :title
  validate                :check_date_not_in_future
  
  scope             :only_parents,  { :conditions => [ "parents = '' OR parents IS NULL" ] }
  scope             :from_noteable, lambda { |n, t| { :conditions => [ 'noteable_id = ? AND noteable_type = ?', n, t ] } }
  

  # Acts as?
  acts_as_resource
  acts_as_content         :reflection => :noteable
  
  
  def cache_permission_to_replay(user)
    @@replay_authorize.nil? ? (@@replay_authorize = self.authorize?(:create, :to => user)) : @@replay_authorize
  end
  
  def cache_permission_to_edit(user)
    @@edit_authorize.nil? ? (@@edit_authorize = self.authorize?(:update, :to => user)) : @@edit_authorize
  end
    
  # Notes global Permissions
  authorizing do |user, permission|
    if user.is_a?(User)
      user.has_any_permission_to(permission, noteable_fake_mode.to_sym, :on => Site.current)
    end || nil
  end
  
  authorizing do |user, permission|
    if user.is_a?(User) and self.container.is_a?(Activist)
      organizations = self.container.activists_collaborations.map(&:organization)
      organizations.inject(false) do |has_permission, organization|
        has_permission = true if user.has_any_permission_to(permission, noteable_fake_mode.to_sym, :on => organization)
        has_permission 
      end
    end || nil
  end
  
  # By Notes Type aka Container
  # Special permissions are over notes
  authorizing do |user, permission|
    (self.container and self.container.authorize?([permission, noteable_fake_mode.to_sym ], :to => user, :default => nil)) || nil
  end
  
  # By global notes over container FIXME ask if true
#   authorizing do |user, permission|
#     (self.container and self.container.authorize?(permission, :to => user)) 
#   end
  

  # Note thread stuff
  def is_parent?; 
    self.parents.nil? or self.parents.empty?
  end
  
  
  def thread
    return [] if not self.is_parent?
    
    notes_in_thread_by_parent
  end
  
  
  def direct_descendants(collection)
    collection.select{ |n| n.parents == ("#{ self.parents ? self.parents : '' }#{ self.id }/") } 
  end
  
  def descendants(collection)
    collection.select{ |n| n.parents.include?("#{ self.parents ? self.parents : '' }#{ self.id }/") } 
  end  
  
  
  def childs
    # if child note, return its childs, and not all
    if self.parents.present?
      return thread.select{ |n| n.parents.length > ("#{ self.parents ? self.parents : '' }#{ self.id }/").length }
    end
    
    thread
  end
    
  def check_date_not_in_future
    self.errors.add :base, :monitoring_date_future if monitoring_date.present? && monitoring_date > Date.today
  end
  
    
  def check_children_before_destroy
    return true if childs.empty?
    
    errors.add :base, :has_children && false
  end

  def self.fast_search_fields
    ['notes.title', 'notes.body' ]
  end
 
  # FIXME 
  # CHANGE IT
  def self.get_by_agent(agent, options = {})
    ret = []
    ActivistNote.find(:all, options).each do |note|
      if note.authorize?(:update, :to => agent )
        ret << note
      end
    end
    ret
  end
  
  def to_title
    title
  end
  
  def noteable_fake_mode
    "#{ self.container.class.model_name }Note"
  end
  
  def h_author
    author ? author.full_name : I18n.t('note.no_creator')
  end
  
  
#   def authorize?(permission, options = {})
#     return super if noteable.nil?
#     agent = options[:to] || Anyone.current
#     ret = super
#     if ret
#       ret = noteable.authorize?(permission, options)
#       if !ret && [:create, :update, :destroy].include?(permission)
#         ret = noteable.authorize?(:update, options)
#       end
#     end
#     return ret
#   end
#   
    
  private 
  def notes_in_thread_by_parent
    Note.find(:all, { :conditions => [ 'parents like ?', "#{ self.id }/%" ] })
  end
  

  
#>>>>>NOTES

end
