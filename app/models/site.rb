#FIXME: INDEPENDIZE dependency from its path!
require_dependency "#{Rails.root}/vendor/gems/station/app/models/site"

class Site

  attr_accessible :name, :description, :create_permissions_as_roles, :email

  acts_as_stage :admissions => false
  
  scope :orderby_name, { :order => 'name ASC' }
  
  def full_name
    name
  end
  
  def to_title
    full_name
  end

end
