class HomeController < ApplicationController
  
  def index
    @home_actions = {
      :new_activist => {
        :url => new_activist_path,
        :icon => :to_activist,
        :allowed => current_user.has_any_permission_to(:create, :activist)
      },
      :new_hr_school => {
        :url => new_hr_school_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:create, :hr_school)
      },
      :edit_activists => {
        :url => activists_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:update, :activist)
      },
      :view_interesteds => {
        :url => interesteds_path,
        :icon => :users,
        :allowed => current_user.has_any_permission_to(:read, :interested)
      },
      :create_campaignaction => {
        :url => new_campaignaction_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:create, :performed_action)
      },
      :saved_searches => {
        :url => saved_searches_path,
        :icon => :saved_search,
        :allowed => true
      },
      :view_activists => {
        :url => activists_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:read, :activist)
      },
      :view_talks => {
        :url => talks_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:read, :talk)
      },  
      :manage_users => {
        :url => users_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:config, :site, :on => Site.current)
      },  
      :manage_roles => {
        :url => roles_path,
        :icon => :view_mine,
        :allowed => current_user.has_any_permission_to(:config, :site, :on => Site.current)
      },  
    }
    
    @related_organizations = current_user.related_organizations.sort_by{|o| [o.class.name, o.name]}
  end
  
end
