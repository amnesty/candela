class SearchController < ApplicationController
  
  before_filter :check_load_saved_search, :only => :index
  before_filter :search_what, :only => :index
  
  
  def index
    @items = []

    check_load_saved_search
    
    if params[:commit]
      @items = @klass.advanced_search(params, current_agent) || []
      @search_results_count = @items.count
      
      check_store_saved_search
      
    end

    respond_to do |format|
      format.html { 
        @items_per_page = params[:per_page]  || 30
        @items = @items.paginate(:page => params[:page], :per_page => @items_per_page) 
      }
      format.csv  { 
        @items = @klass.sort_for_csv(@items)
        csv_string = render_to_string :template => "search/index", :layout => nil           
        send_data csv_string, :type => "text/plain",  :filename => "resultado_busqueda.csv", :disposition => 'attachment'
      }
    end
  end
  
  def organizations_for
    if params[:organization_type] and ActivistsCollaboration.organization_types.include?(params[:organization_type])
      @organizations = ActivistsCollaboration.organizations_by_type( "Member" + params[:organization_type])
      render :template => 'search/organizations_id_for_search', :layout => nil
    else
      render :text => 'fail', :status => 404
    end
  end
    
  def autonomic_teams_for
    autonomy = params[:organization_id].nil? || params[:organization_id].empty? ? nil : Autonomy.find(params[:organization_id])
    render :partial => 'search/autonomic_teams_for_search', :layout => false, :locals => {:autonomy => autonomy}
  end

  private
  def search_what
    searcheable_klasses = [ "activists", "activists_collaborations", "hr_schools", "campaignactions", "custom_actions", "interesteds", "talks", 
                            "local_organizations", "se_teams", "countries", "autonomies", "committees", "alerts" ]
    unless searcheable_klasses.include?(params[:what])
      flash.now[:error] = t('search.none')
      render(:file => "#{Rails.root}/public/404.html", :status => 404)
    else
      @klass = params[:what].camelize.singularize.constantize
    end
  end

  ########################################################
  # Methods to manage saved searches in index action
  
  EXCLUDED_PARAMS_IN_SAVED_SEARCH = [ :load_saved_search, :store_saved_search, :update_saved_search_id, :new_saved_search_name ]
  
  def check_load_saved_search
    if !params[:load_saved_search].blank?
      saved_search = SavedSearch.find_by_id params[:load_saved_search]      
      if saved_search
        return not_authorized unless saved_search.authorize?(:read, :to => current_agent)
        params.merge! saved_search.params
        flash.now[:notice] = I18n.t('form.actions.loaded', {:model => Gx.t_model('saved_search') + " '" + saved_search.name + "'" })
      else
        flash.now[:alert] = Gx.proper(I18n.t('form.actions.not_loaded', {:model => Gx.t_model('saved_search')}))
      end
    end
  end
  
  def check_store_saved_search  
    if params[:store_saved_search]
    
      if !params[:update_saved_search_id].blank?
        saved_search = SavedSearch.find_by_id params[:update_saved_search_id]
        if saved_search && saved_search.update_attribute(:params, params.except(*EXCLUDED_PARAMS_IN_SAVED_SEARCH))
          flash.now[:notice] = I18n.t('form.actions.updated', {:model => Gx.t_model('saved_search') + " '" + saved_search.name + "'" })
        else
          flash.now[:alert] = I18n.t('form.actions.not_updated', {:model => Gx.t_model('saved_search')})
        end
        
      elsif !params[:new_saved_search_name].blank?
        saved_search = SavedSearch.new :name => params[:new_saved_search_name], 
                                        :target => params[:what], 
                                        :user => current_agent, 
                                        :params => params.except(*EXCLUDED_PARAMS_IN_SAVED_SEARCH)
        if saved_search.save
          flash.now[:notice] = I18n.t('form.actions.created', {:model => Gx.t_model('saved_search') + " '" + saved_search.name + "'" })
        else
          flash.now[:alert] = I18n.t('form.actions.not_created', {:model => Gx.t_model('saved_search')})
        end
        
      else
        flash.now[:alert] = I18n.t('activerecord.errors.models.saved_search.attributes.base.name_or_id_required')
      end
      
    end
  end
  
  
end
