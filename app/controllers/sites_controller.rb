class SitesController < ApplicationController
  include ActionController::AIController

  authorization_filter [:config,:Site],  :site, :only => [ :show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if current_site.update_attributes(params[:site])
        flash[:success] = t('site.updated')
        format.html { redirect_to site_path }
        format.xml  { head :ok }
      else
        @site = current_site
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  def set_resource
    @resource = @site = current_site
  end

end
