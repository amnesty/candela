class SavedSearchesController < ApplicationController
  include ActionController::AIController

  authorization_filter :read,   :saved_search, :only => [ :show ]
  authorization_filter :update, :saved_search, :only => [ :edit, :update]
  authorization_filter :destroy, :saved_search, :only => [ :delete, :destroy ]

  def index
    super({:sort => lambda { |resources| resources.sort_by{|s| [s.target, s.name]} } })
  end
  
  def index_by_target
    @saved_searches = SavedSearch.can_see(current_agent).sort_by{|s|[s.target,s.name]}
    render :template => "saved_searches/index_by_target", :locals => { :collection => @resources, :klass => model_class }
  end
 
end
