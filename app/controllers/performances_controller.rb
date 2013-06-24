class PerformancesController < ApplicationController
  include ActionController::AIController

  authorization_filter :create,  :performance, :only => [ :new, :create ]
  authorization_filter :read,    :performance, :only => [ :show, :index ]
  authorization_filter :update,  :performance, :only => [ :edit, :update]
  authorization_filter :destroy, :performance, :only => [ :delete, :destroy ]

  before_filter :set_user,         :except => [:stages_for_performances]
  before_filter :set_agent,        :except => [:stages_for_performances]
  
  
  # create performances is special because create, usuarlly, more than one at once.
  # So, wat we update, actually, us user, not performance.
  def create 
    respond_to do |format|
      format.html {
        if @user.update_performances(params[:performance], @performance)
          flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
          redirect_to user_performances_path(@user), :referer => params[:referer]
        else
         # $stderr.puts @user.class.columns.map{|c| "#{c.name }: #{ @user.send(c.name).nil? ? "nil" : @user.send(c.name).to_s.length }" }
          render :template => "shared/new"
        end
      }
    end
  end
    
    
  def index
    @performances = @user.performances.paginate(:page => params[:page], :per_page => 10 )
   
    respond_to do |format|
      format.html { render :template => "shared/index", :locals => { :collection => @performances, :klass => Performance }}
    end
  end

  def update
    respond_to do |format|
      format.html {
        if @user.update_performances(params[:performance], @performance)
          flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
          redirect_to user_performances_path(@user), :referer => params[:referer]
        else
          render :template => "shared/edit"
        end
      }
    end
  end
    
  def destroy
    resource
    respond_to do |format|
      if @resource.destroy
        format.html {
          flash[:success] = t(:deleted, :scope => @resource.class.to_s.underscore)
          redirect_to user_performances_path(@user), :referer => params[:referer]
        }
        format.xml  { head :ok }
        format.atom { head :ok }
      else
        format.html {
          flash[:error] = t(:not_deleted, :scope => model_class.to_s.underscore)
          flash[:error] << @resource.errors.to_xml
          redirect_to :action => :index
        }
        format.xml  { render :xml => @resource.errors.to_xml }
        format.atom { render :xml => @resource.errors.to_xml }
      end
    end
  end
  

  
  def stages_for_performances
    if params[:stage_type]
      @stages = Performance.organizations_for_stage(params[:stage_type])
    elsif params[:parent_stage_type] && params[:parent_stage_id] && params[:child_stages_method]
      parent_stage = params[:parent_stage_type].constantize.find_by_id(params[:parent_stage_id]) 
      @stages = Performance.organizations_for_stage(params[:stage_type], {:parent_stage => parent_stage, :child_stages_method => params[:child_stages_method]})
    else
      @stages = []
    end
    render :template => 'performances/stages_as_options', :layout => nil
  end

=begin
  The creation, update and removal of permissions are all done as sets of permissions,
  grouped by role or by organization. So, even though the controller is designed for
  updating a record at a time, here we are, actually, updating a set of records.
  If the new set of roles already exist, we just discard them.
=end
  
  private 
#   def save_all_performances
#     if current_site.create_permissions_as_roles      
# #      @user.clear_performances_for_organization!(@performance.stage_type, @performance.stage_id)
#       params[:performance]["role_id"].each do |role_id|
#         perf = @performance.clone
#         perf.role_id = role_id
#         if @user.performances.collect { |p| [p.agent_id, p.agent_type, p.role_id, p.stage_id, p.stage_type] }.index( [perf.agent_id, perf.agent_type, perf.role_id, perf.stage_id, perf.stage_type] ) == nil
#           @user.performances << perf
#         end
#       end
#     else
# #      @user.clear_performances_for_role!(@performance.role_id)
#       params[:performance]["stage_id"].each do |stage_id|
#         perf = @performance.clone
#         perf.stage_type = params[:performance]["stage_type"]
#         perf.stage_id = stage_id
#         if @user.performances.collect { |p| [p.agent_id, p.agent_type, p.role_id, p.stage_id, p.stage_type] }.index( [perf.agent_id, perf.agent_type, perf.role_id, perf.stage_id, perf.stage_type] ) == nil
#           @user.performances << perf
#         end
#       end
#     end
#   end

#   def delete_all_performances
#     if current_site.create_permissions_as_roles      
#       @user.clear_performances_for_organization!(@performance.stage_type, @performance.stage_id)
#     else
#       @user.clear_performances_for_role!(@performance.role_id)
#     end
#   end
  
  def set_user
    @user = User.find(params[:user_id])
    @container = @user
  end
  
  def set_agent
    @performance.agent = @user
  end

    
  
end
