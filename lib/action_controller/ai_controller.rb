module ActionController

  module AIController

    class << self
      def included(base) #:nodoc:
#         base.send :include, ActionController::Station unless base.ancestors.include?(ActionController::Station)
        base.class_eval do                                     # class Article
          alias_method controller_name.singularize, :resource  #   alias_method :article, :resource
          helper_method controller_name.singularize            #   helper_method :article
        end                                                    # end
        base.send :include, ActionController::Authorization unless base.ancestors.include?(ActionController::Authorization)
        base.send :before_filter, :set_resource, :only => [ :show, :edit, :new, :update, :delete, :destroy ]
      end
    end

    
    # GET / 
    def index(options = {}, &block)

      # Filters
      params[:index_filters] ||= (default_filters_for_index if self.respond_to?(:filters_for_index)) || {}

      # Fast Search Conditions
      conditions = options[:conditions] || []
      
      if params.include?(:query) and !params[:query].blank?
        if model_class.respond_to?("fast_search_fields")
          @search_fields = model_class.fast_search_fields
        else
          @search_fields = [ "#{model_class.to_s.tableize}.name"]
        end
        @search_terms = Gx.regexp_acutes params[:query].split(' ').collect{|s|ActiveRecord::Base.connection.quote_string(s)}
        query_strings = @search_terms.map{|search_term| @search_fields.map{ |field| "CONVERT (#{field} USING latin1) REGEXP CONVERT ('#{ search_term }' USING latin1)" }.join(" OR ") }
        conditions << query_strings.map{|query_string| "(#{query_string})"}.join(" AND ")
      end
            
      # Parameters for query
      query_to   = options[:query_to] || model_class.in_container(current_container)
      search_params = {}
      order = params[:order] || (model_class.default_order_field if model_class.respond_to?("default_order_field")) || "#{ model_class.table_name }.id"
      direction  = params[:direction] || (model_class.default_order_direction if model_class.respond_to?("default_order_direction")) || "ASC"
      per_page   = params[:per_page]  || 30
      
#      @resources = query_to.advanced_search(search_params,current_agent).paginate(:page => params[:page],
#                                                                   :per_page => per_page,
#                                                                   :conditions => conditions.join(' AND '))

      @resources = query_to.include_in.can_see(current_agent)
      @resources = @resources.filter_with_definitions(filters_for_index, params[:index_filters]) if self.respond_to?(:filters_for_index)
      # Resources must be counted apart to avoid bad counts in will_paginate. See http://archive.railsforum.com/viewtopic.php?id=15530
      num_resources = @resources.collect(&:id).count 
      @resources = @resources.column_sort(order, direction).paginate(:page => params[:page], :per_page => per_page, :conditions => conditions.join(' AND '), :total_entries => num_resources)
      instance_variable_set "@#{ model_class.name.tableize }", @resources
 
      # Needed? FIXME
      if block
        yield
      else
        respond_to do |format|
          format.html { render :template => "shared/index", :locals => { :collection => @resources, :klass => model_class } }
          format.js
          format.xml  { render :xml => @resources }
          format.atom
        end
      end
    end
    
    
    # GET /object/:id
    def show
      respond_to do |format|
        format.html { render :template => "shared/show" }
        format.xml  { render :xml => @resource }
        format.atom
      end
    end

    # GET /object/:id/edit
    def edit
      respond_to do |format|
        format.html { render :template => "shared/edit" }
      end
    end
    
    
    # GET /object/new
    def new
      respond_to do |format|
        format.html { render :template => "shared/new" }
        format.xml  { render :xml => @resource }
      end
    end
    
    
    # POST /objects
    def create
      # assign author
      @resource.author = current_agent if @resource.respond_to?(:author=)

      respond_to do |format| 
        if @resource.save
          flash[:success] = t(:created, :scope => @resource.class.name.underscore)
           
          format.html { 
           redirect_to create_with_success
          }
          format.xml  { render :xml      => @resource, :status   => :created, :location => @resource }
          format.atom { render :action    => 'show', :status => :created, :location => polymorphic_url(@resource, :format => :atom) }
        else


          format.html { render :template => "shared/new" }
          format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
          format.atom { render :xml => @resource.errors.to_xml, :status => :bad_request }
        end
      end
    end
    
    # GET /object/:object_id/delete
    def delete
      respond_to do |format|
        format.html {
          render :template => "shared/delete", :layout => 'application'
        }
      end
    end

    def update
      respond_to do |format|
        format.html {
          if @resource.save
            flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
            redirect_to update_with_success
          else
            render :template => 'shared/edit'
          end
        }

        format.atom {
          if @resource.save
            head :ok
          else
            render :xml => @resource.errors.to_xml, :status => :not_acceptable
          end
        }

      end
    end


    def destroy
            
      respond_to do |format|
        
        if @resource.destroy
          other_resource = @resource.class.new
          
          format.html {
            flash[:success] = t(:deleted, :scope => @resource.class.to_s.underscore)
            redirect_to polymorphic_url( [@container, other_resource ]) 

          }
          format.xml  { head :ok }
          format.atom { head :ok }
        else
          format.html {
            flash[:error] = t(:not_deleted, :scope => model_class.to_s.underscore)
            flash[:error] << @resource.errors.to_xml
            if @container
              redirect_to eval("#{@container.class.name.underscore}_#{@resource.class.name.tableize}_path(@container.id)")
            else
              redirect_to :action => :index
            end
          }
          format.xml  { render :xml => @resource.errors.to_xml }
          format.atom { render :xml => @resource.errors.to_xml }
        end
      end
    end
    
    
    def create_with_success
      [ @container, @resource ]
    end
    
    
    def update_with_success
      [ @container, @resource ]
    end

    protected
    def t(message_id, options = {})
      if options[:scope]
        model = Gx.t_model(options[:scope])
        options.delete(:scope)
        options.merge!(:model => model)
      end
      if message_id == :updated
        message_id = "form.actions.updated"
      elsif message_id == :created
        message_id = "form.actions.created"
      elsif message_id == :deleted
        message_id = "form.actions.deleted"
      elsif message_id == :not_deleted
        message_id = "form.actions.not_deleted"
      end
      Gx.proper(I18n.t(message_id, options))
    end

    # Finds the current Resource using model_class
    #
    # If params[:id] isn't present, build a new Resource
    def resource
      set_resource
    end
    
    def set_resource
      begin
        @container = current_container if @container.nil?
        
        if @resource.nil?

          if model_class.acts_as?(:content) and @container

            if params[model_class.name.underscore.to_sym].present?

              if params[:id].present?
                r = @container.__send__(model_class.name.tableize).include_in.find(params[:id])
                r.attributes = params[model_class.name.underscore.to_sym]
              else
                r = @container.__send__(model_class.name.tableize).new( params[model_class.name.underscore.to_sym] )
              end
            else
              
              if params[:id].present?

                r = @container.__send__(model_class.name.tableize).include_in.find(params[:id])
              else
                r = model_class.new
              end
            end
          else

            if params[model_class.name.underscore.to_sym].present?
              if params[:id].present?

                r = model_class.find(params[:id])
                r.attributes = params[model_class.name.underscore.to_sym]
              else
                r = model_class.new(params[model_class.name.underscore.to_sym])
              end
            else
              if params[:id].present?

                r = model_class.include_in.find(params[:id])
              else
                r = model_class.new
              end
            end
          end
          @resource = instance_variable_set( "@#{ model_class.name.underscore }", r )
        else
          instance_variable_set( "@#{ model_class.name.underscore }", @resource )
        end
      end
    end

    
      
  end
end
