class PublicController < ApplicationController

  skip_before_filter :authenticate_user!
  layout 'public_layout'  

  def new_hr_school
    @hr_school         = HrSchool.new
  end

  def create_hr_school
    
    @hr_school = HrSchool.new(params[:hr_school])
    @hr_school.from_public = true
    @hr_school.verify_privacity = true
        
    if @hr_school.save
      flash[:notice] = t('form.form_send', :scope => 'hr_school')
      redirect_to :action => 'confirm_hr_school', :hr_school => @hr_school.id
    else
      render :action => "new_hr_school"
    end
  end

  def confirm_hr_school
    @hr_school = HrSchool.find(params[:hr_school])
  end

  def list_hr_schools
    @hr_schools = HrSchool.where(:status => I18n.t(:active, :scope => [:hr_school, :statuses])).
                          includes(:province).order('provinces.name,city,hr_schools.name')
  end

  def new_interested
    @interested = Interested.new
  end

  def create_interested
    
    @interested             = Interested.new(params[:interested])
    @interested.from_public = true
    @interested.informed_through = InformedThrough.web
    @with_more_information = true if params[:include_moar].present?
    @interested.verify_privacity = true
      
        
    if @interested.different_residence_country
      render :action => 'different_residence_country'
    elsif params[:with_moar].present?
      @with_more_information = true
      render :template => 'public/new_interested'
    elsif @interested.save
      flash[:notice] = t('form.form_send', :scope => 'interested')
      redirect_to :action => 'confirm_interested', :interested => @interested.id
    else
      render :action => "new_interested"
    end
  end

  def confirm_interested
    @interested = Interested.find(params[:interested])
  end

  def different_residence_country
    render 'different_residence_country'
  end
  
  # The following functions are for AJAX calls inside public forms
  def provinces_for
    if params[:cp]
      if params[:cp].empty?
        @provinces = Province.orderby_name
      else
        city = City.find(:first, :conditions => [ 'cp = ?', params[:cp]])
        if city.nil? == false
          @provinces = Province.find(:all, :order => 'name', :conditions => [ "id = ?", city.province_id ])
        else
          @provinces = Province.orderby_name
        end
      end
      render :template => 'countries/provinces_as_options', :layout => nil
    else
      render :text => '', :status => nil
#      render :file => "#{ Rails.root }/public/404.html", :status => 404, :layout => nil
    end
  end

  def cp_for
    begin
      city = City.find(params[:city_id])
      render :text => city.cp, :layout => nil
    rescue
      render :text => '', :status => nil
#      render :file => "#{ Rails.root }/public/404.html", :status => 404, :layout => nil
    end
  end

  def cities_for
    if params[:cp]
      begin
        @cities = [*City.find_by_cp(params[:cp])]
        render :template => 'provinces/cities_as_options', :layout => nil
      rescue
        render :text => '', :status => nil
      end
    elsif params[:province_id]
      begin
        province = Province.find(params[:province_id])
        @cities  = province.cities

        render :template => 'provinces/cities_as_options', :layout => nil
      rescue
        render :text => '', :status => nil
#        render :file => "#{ Rails.root }/public/404.html", :status => 404, :layout => nil
      end
    else
      render :text => '', :status => nil
#      render :file => "#{ Rails.root }/public/404.html", :status => 404, :layout => nil
    end
  end
  
#---------------------------------------------------
# LOCALE FROM PARAMS

  before_filter :set_i18n_locale_from_params, :only => [:new_hr_school, :create_hr_school, :confirm_hr_school, :list_hr_schools]

  protected

    def set_i18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.include?(params[:locale].to_sym)
          I18n.locale = params[:locale]
        else
          I18n.locale = I18n.default_locale
          flash.now[:error] = "#{params[:locale]} translation not available"
        end
      else
        I18n.locale = I18n.default_locale
      end
    end

    def default_url_options
      { :locale => I18n.locale }
    end

end
