#FIXME: INDEPENDIZE dependency from its path!
require_dependency "#{Rails.root}/vendor/gems/station/app/models/role"

class Role < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord
  
  attr_accessible :name, :description, :permission_ids
  
  def to_title
    name
  end
  
  def full_name
    to_title
  end
  
  
  def self.with_permission(permission_id)
    find(:all, :include => 'permissions', :conditions => [ "permissions.id = ?",  permission_id ])
  end
  
end
