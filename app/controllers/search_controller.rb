class SearchController < ApplicationController
  
  before_filter :search_what, :only => :index
  
  
  def index
    @items = []
    if params[:commit]
      @items = @klass.advanced_search(params, current_agent) || []
      @search_results_count = @items.count
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
    
  private
  def search_what
    searcheable_klasses = [ "activists", "activists_collaborations", "hr_schools", "campaignactions", "interesteds", "talks", 
                            "local_organizations", "se_teams", "countries", "autonomies", "committees", "alerts" ]
    unless searcheable_klasses.include?(params[:what])
      flash[:error] = t('search.none')
      render(:file => "#{Rails.root}/public/404.html", :status => 404)
    else
      @klass = params[:what].camelize.singularize.constantize
    end
  end
end
