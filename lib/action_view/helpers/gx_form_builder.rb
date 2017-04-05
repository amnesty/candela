module ActionView
  module Helpers

    class GxFormBuilder < ActionView::Helpers::FormBuilder

      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper

      def show_buttons(request)
        
        ''.tap do |html|
          referer = request.params[:referer] || request.referer
          
          html << "<input type=\"hidden\" name=\"referer\" value=\"#{ referer }\" />"
          html <<  button_to_function(I18n.t("form.buttons.back"), "document.location = '#{ referer }'", :class => 'action_cancel' )
          
          permission = false
          case request.params[:action].to_sym
            when :new, :create
              permission = :create
            when :edit, :update
              permission = :update
            when :delete, :destroy
              permission = :destroy
            when :show, :index
              permission = :read
          end
          if permission and object.authorize?(permission, :to => @template.current_agent)
            html << submit( I18n.t("form.buttons.#{ permission }"), :class => 'action_apply', :name => 'commit' )
          end
          html
        end.html_safe
      end

      # outputs a label with class required added if the form is enabled
      def label_required(method, text = nil, options = {})
        unless self.options[:disabled]
          options.merge!({ :class => "required" })
        end
        label(method, text, options)
      end

      def label(method, text = nil, options = {})
        # path translation. Rails fails to translate label.object
        translation = text || Gx.t_attr( "#{ @object_name }.#{ method }" )
        super(method, translation, options)
      end

      # outputs a text disabled if the form is disabled
      def text_field(method, options = {})
        super(method, self.options.merge(options) )
      end

      def password_field(method, options = {})
        super(method, self.options.merge(options) )
      end

      # outputs a select disabled if the form is disabled
      def select(method, choices = [], options = {}, html_options = {})
        if self.options[:disabled]
          html_options.merge!(:disabled => 'disabled' )
        end
        super(method, choices, options, html_options)
      end

      def date_select(method, options = {}, html_options = {})
        if self.options[:disabled]
          html_options.merge!( :disabled => 'disabled')
        end
        html_options.merge!( :class => 'datetime_select')
        if options[:start_year] == nil 
          options[:start_year] = Time.now.year - 20
        end
        if options[:end_year] == nil 
          options[:end_year] = Time.now.year + 1
        end
        super( method, options, html_options )
      end

      def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
        if self.options[:disabled]
          options.merge!( :disabled => 'disabled' )
        end
        super( method, options, checked_value, unchecked_value)
      end

      def text_area(method, options = {})
        if self.options[:disabled]
          options.merge!( :disabled => 'disabled' )
        end
        super( method, options )
      end

      def date_field(method, options = {})
        thedate = eval( "self.object.#{method}" )
        field = @object_name + "_" + method.to_s
        options.merge! :size => 8, :maxlength => 10, :readonly => true
        options[:value] ||= thedate.nil? ? "" : I18n.localize(thedate.to_date, :format => '%d-%m-%Y')
        self.text_field(method, options) <<
        javascript_tag("$('##{field}').datepicker();")
      end

      def cp_field(method, options = {})
        prefix   = "#{ options.delete(:name_prefix) }" || ''
        html_options = { :maxlength => 5}
        @template.content_for :head do
          javascript_tag "
            addAutocompleteInputCallback('#{ @object_name }#{ prefix }_cp', '#{@template.send('city_for_cp_path')}', 'cp', '#{ @object_name }#{ prefix }_city');
            addAutocompleteInputCallback('#{ @object_name }#{ prefix }_cp', '#{@template.send('provinces_for_cps_path')}', 'cp', '#{ @object_name }#{ prefix }_province_id');
            "
        end

        text_field(method, options.merge(html_options))
      end
      
      def file_field(method, options = {})
        super(method, self.options.merge(options) )
      end
      
      def select_province(method, options = {}, html_options = {})
        prefix           = "#{ options.delete(:name_prefix) }" || ''
        collection       = Province.orderby_name.collect { |p| [p.name, p.id] }
        object_options   = { :include_blank => true, :selected => self.object.send(method) }
        @template.content_for :head do
          javascript_tag "addAutocompleteInputCallback('#{ @object_name }#{ prefix }_province_id', '#{@template.send('cities_for_province_path')}', 'province_id', '#{ @object_name }#{ prefix }_city');"
        end
        self.select(method, collection, options.merge(object_options), html_options)
      end
      
      def select_city(method, options = {}, html_options = {})
        prefix           = "#{ options.delete(:name_prefix) }" || ''
#        city             =  City.name_or_id_equals(object.send(method)).first
        city = (City.find_by_id object.send(method)) || City.find_by_name(object.send(method))
        collection       =  city ? [ city.name ] : [ @template.t('country.select_cp_or_province') ]
        @template.content_for :head do
          javascript_tag "addAutocompleteInputCallback('#{ @object_name }#{ prefix }_city', '#{@template.send('cp_for_city_path')}', 'city_id', '#{ @object_name }#{ prefix }_cp');"
        end
        select(method, collection, options, html_options)
      end
      
      # Wrapper method. FIXME
      # No idea why errors_messages rails method is returning {{attribute}}:{{message}} instead of translation. though have something related with Gx santis module overwrite t_model method
      def errors_in_form
	unless @object.errors.count.zero?
	  object_t_name  = Gx.t_model @object_name
	  header_message = I18n.t(:header, :count => @object.errors.count, :model => object_t_name, :scope => [ :activerecord, :errors, :template ])
	  string         = content_tag(:h2, header_message, :model => @object_name) unless header_message.blank?

	  string << @object.errors.inject('</ul>') do |body_str, error|
	    error_field   = error.first
	    error_message = error.last 
	    body_str << "<li>#{ I18n.t(error_field, :scope => [ :activerecord, :attributes, @object_name]) }: #{ error_message }</li>".html_safe
	    body_str.html_safe
	  end
	  string << "</ul>".html_safe
	  @template.content_tag(:div, string.html_safe, :class => "errorExplanation")
	end
      end
    end
  end
end
