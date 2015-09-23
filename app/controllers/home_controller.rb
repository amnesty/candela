class HomeController < ApplicationController
  
  def index
    @home_actions = {
      :new_activist => {
        :url => new_activist_path,
        :icon => :to_activist,
        :allowed => current_user.has_any_permission_to(:create, :activist)
      },
      :view_interesteds => {
        :url => interesteds_path,
        :icon => :users,
        :allowed => current_user.has_any_permission_to(:read, :interested)
      },
      :saved_searches => {
        :url => saved_searches_path,
        :icon => :saved_search,
        :allowed => true
      },
    }
    
    @related_organizations = current_user.related_organizations.sort_by{|o| [o.class.name, o.name]}
  end
  
end
