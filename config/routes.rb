AiVoluntariado::Application.routes.draw do

  devise_for :users, :skip => [:registrations]
  devise_scope :user do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
  end
  resources :users do
    get :delete, :on => :member
    
    resources :performances do 
      get :delete, :on => :member
    end

    resources :organizations_trackings do
      get :delete, :on => :member
      get :destroy_all, :on => :collection
    end
      
  end

  resources :roles do
    get :delete, :on => :member
  end

  resource :site, :only => [:show,:edit,:update]

  match '/monitoring' => "monitoring#index", :as => :monitoring

  resources :activists do

    member do 
      get :delete
      get :leave
      get :clear
      get :rejoin
      get :admin_request
      put :send_admin_request
    end

    resources :activists_collaborations do 
      get :delete, :on => :member
    end

    resources :notes do
      get :delete, :on => :member
    end

  end

  resources :campaignactions do
    get :delete, :on => :member
  end

  resources :custom_actions do
    get :delete, :on => :member
  end

  resources :campaigns do
    get :delete, :on => :member
    get :show_info, :on => :collection
  end

  resources :hr_schools do
    get :delete, :on => :member
    resources :notes do 
      get :delete, :on => :member
    end
  end

  resources :mail_template_collections

  resources :provinces

  resources :talks do
    get :delete, :on => :member
  end

  resources :interesteds do
    get :delete, :on => :member
    get :to_activist, :on => :member
    get :prepare_pdf, :on => :member
    put :send_pdf, :on => :member
    get :prepare_mail, :on => :member
    put :send_mail, :on => :member

    resources :interested_communications, :path => :communications do 
      get :delete, :on => :member
      resources :notes do
        get :delete, :on => :member    
      end
    end

  end

  # ROUTES FOR ORGANIZATIONS

  resources :autonomies do
    get :delete, :on => :member    
    resources :notes do
      get :delete, :on => :member 
    end
    resources :autonomic_teams do
      get :delete, :on => :member 
    end
    resources :activists_collaborations do
      get :delete, :on => :member 
      get :autocomplete_activist_search, :on => :collection
    end
    resources :talks do
      get :delete, :on => :member 
    end
    resources :organization_on_offs do
      get :delete, :on => :member 
    end
    resources :campaignactions do
      get :delete, :on => :member 
    end    
    resources :custom_actions do
      get :delete, :on => :member 
    end    
  end

  resources :committees do
    get :delete, :on => :member    
    resources :notes do
      get :delete, :on => :member 
    end
    resources :activists_collaborations do
      get :delete, :on => :member 
      get :autocomplete_activist_search, :on => :collection
    end
    resources :organization_on_offs do
      get :delete, :on => :member 
    end
  end

  resources :countries do
    get :delete, :on => :member    
    resources :notes do
      get :delete, :on => :member 
    end
    resources :activists_collaborations do
      get :delete, :on => :member 
      get :autocomplete_activist_search, :on => :collection
    end
    resources :organization_on_offs do
      get :delete, :on => :member 
    end
    resources :campaignactions do
      get :delete, :on => :member 
    end    
  end

  resources :local_organizations do
    get :delete, :on => :member    
    resources :notes do
      get :delete, :on => :member 
    end
    resources :activists_collaborations do
      get :delete, :on => :member 
      get :autocomplete_activist_search, :on => :collection
    end
    resources :talks do
      get :delete, :on => :member 
    end
    resources :organization_on_offs do
      get :delete, :on => :member 
    end
    resources :campaignactions do
      get :delete, :on => :member 
    end    
    resources :custom_actions do
      get :delete, :on => :member 
    end    
  end

  resources :se_teams do
    get :delete, :on => :member    
    resources :notes do
      get :delete, :on => :member 
    end
    resources :activists_collaborations do
      get :delete, :on => :member 
      get :autocomplete_activist_search, :on => :collection
    end
    resources :organization_on_offs do
      get :delete, :on => :member 
    end
  end

  #ROUTES FOR EVENT RECORDS
  EventRecord.child_classes.prepend('EventRecord').each do |klass_name|
    resources klass_name.underscore.pluralize, :controller => 'event_records', :defaults => (klass_name != 'EventRecord' ? {:type => klass_name}:{}) do 
      get :delete, :on => :member    
      resources :notes do
        get :delete, :on => :member    
      end
    end
  end if EventRecord.table_exists?

  #ROUTES FOR ALERTS

  resources :alerts do
    get :delete, :on => :member    
    resources :notes do
      get :delete, :on => :member    
    end
  end

  # Routes for AJAX requests
  match '/stages_for_performances'        => "performances#stages_for_performances", :as => :stages_for_performances
  match '/organizations_for_hr_schools'   => "hr_schools#organizations_for",         :as => :organizations_for_hr_schools
  match '/organizations_for_search'       => "search#organizations_for",             :as => :organizations_for_search
  match '/collaboration_types_for_search' => "search#collaboration_types_for",       :as => :collaboration_types_for_search
  match '/autonomic_teams_for_autonomy'   => "autonomies#autonomic_teams_for",       :as => :autonomic_teams_for_autonomy
  
  # Routes for auto_complete
  #TODO: simplify these routes
  match '/auto_complete/talks_as_options_for_interesteds' => 'talks#talks_as_options_for_interesteds', :as => :talks_as_options_for_interesteds_talks
  match '/auto_complete/talks_as_options_for_search'      => 'talks#talks_as_options_for_search',      :as => :talks_as_options_for_search_talks

#  match '/auto_complete/local_organizations_as_options_for_activists_collaborations/:local_organization_id' => 'activists_collaborations#auto_complete_for_activist_search', :as => :auto_complete_for_activist_search_local_organization_activists_collaborations
#  match '/auto_complete/committees_as_options_for_activists_collaborations/:committee_id' => 'activists_collaborations#auto_complete_for_activist_search', :as => :auto_complete_for_activist_search_committee_activists_collaborations
#  match '/auto_complete/se_teams_as_options_for_activists_collaborations/:se_team_id' => 'activists_collaborations#auto_complete_for_activist_search', :as => :auto_complete_for_activist_search_se_team_activists_collaborations
#  match '/auto_complete/countries_as_options_for_activists_collaborations/:country_id' => 'activists_collaborations#auto_complete_for_activist_search', :as => :auto_complete_for_activist_search_country_activists_collaborations
#  match '/auto_complete/autonomies_as_options_for_activists_collaborations/:autonomy_id' => 'activists_collaborations#auto_complete_for_activist_search', :as => :auto_complete_for_activist_search_autonomy_activists_collaborations

  #PUBLIC ROUTES

  # HHRR schools: localized actions
  scope "(:locale)" do
    match '/form_hr_schools'   => 'public#new_hr_school',  :as => :form_hr_schools
    ["new_hr_school", "create_hr_school", "confirm_hr_school", "list_hr_schools"].each do |action_name|
      match "public/#{action_name}" => "public##{action_name}"
    end
  end

  # Interesteds: non-localized actions
  match '/form_voluntariado' => 'public#new_interested', :as => :form_voluntariado
  ["new_interested", "create_interested", "confirm_interested", "different_residence_country"].each do |action_name|
    match "public/#{action_name}" => "public##{action_name}"
  end

  # Ajax request for forms
  match '/provinces_for_cps'              => "public#provinces_for", :as => :provinces_for_cps
  match '/cities_for_province'            => "public#cities_for",    :as => :cities_for_province
  match '/city_for_cp'                    => "public#cities_for",    :as => :city_for_cp
  match '/cp_for_city'                    => "public#cp_for",        :as => :cp_for_city

  # Other static routes
  match '/gen_alerts'        => 'alerts#generate',  :as => :gen_alerts
  match '/search'            => 'search#index',     :as => :search
  match '/admin'             => 'admin#index',      :as => :admin

  root :to => "activists#index"

  # Note: This route will make all actions in every controller accessible via GET requests.
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Uncommment only for route testing purposes
#  match ':controller(/:action(/:id))(.:format)' 

end
