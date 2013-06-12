Rails.application.routes.draw do
#  map.openid_server 'openid_server', :controller => 'openid_server'

#  map.open_id_complete 'session', 
#    { :controller => 'sessions', 
#      :action     => 'create',
#      :conditions => { :method => :get },
#      :open_id_complete => true }

  resources :sessions

  match "login" => 'sessions#new', :as => :login
  match "logout" => 'sessions#destroy', :as => :logout

##  if ActiveRecord::User.table_exists? 
#    if ActiveRecord::Agent.activation_class
#      map.activate 'activate/:activation_code', 
#              :controller => ActiveRecord::Agent.activation_class.to_s.tableize, 
#              :action => 'activate', 
#              :activation_code => nil
#    end

#    if ActiveRecord::Agent::authentication_classes(:login_and_password).any?
#      map.lost_password 'lost_password', 
#                      :controller => ActiveRecord::Agent.authentication_classes(:login_and_password).first.to_s.tableize,
#                      :action => 'lost_password'
#      map.reset_password 'reset_password/:reset_password_code', 
#                    :controller => ActiveRecord::Agent.authentication_classes(:login_and_password).first.to_s.tableize,
#                    :action => 'reset_password',
#                    :reset_password_code => nil
#    end
##  end

#  map.resources :categories
#  map.resources :tags

  resource :site do
    if Site.table_exists?
        resources :performances, :defaults => { :site_id => Site.current.id }
        resources :categories, :defaults => { :site_id => Site.current.id }
        resources *ActiveRecord::Resource.symbols, :defaults => { :site_id => Site.current.id }
    end
  end

#  map.resources *( ( ActiveRecord::Resource.symbols | 
#                 ActiveRecord::Content.symbols  | 
#                 ActiveRecord::Agent.symbols ) - 
#                ActiveRecord::Container.symbols 
#             )

#  ActiveRecord::Container.symbols.each do |container_sym|
#    next if container_sym == :sites
#    map.resources(container_sym) do |container|
#      container.resources(*container_sym.to_class.contents)
#      container.resources :categories
#      container.resources :sources, :member => { :import => :get }
#    end
#  end
#  map.resources :sources, :member => { :import => :get }

#  map.resources :logos

#  map.resources(*(ActiveRecord::Logoable.symbols - Array(:sites))) do |logoable|
#    logoable.resource :logo
#  end

#  map.resources :roles
#  map.resources :invitations, :member => { :accept => :get }

#  map.resources(*ActiveRecord::Stage.symbols - Array(:sites)) do |stage|
#    stage.resources :performances
#    stage.resources :invitations
#    stage.resources :join_requests
#  end

  resources :performances
end
