module ApplicationHelper

  def change_locale_url(locale)
    url_for(params.merge({:locale => locale}) )
  end

  # Rended rounded div box FIXME
  def round_div_box(options = {}, &block)

    options[:padding] ||= true

    ''.tap do |html|
      html << '<div class="rounded-box"><div class="t"><div class="t"><div class="t"></div></div></div>'
      html << "<div class='m#{ options[:padding] ? '_pad' : '' }'>"
    
      html << capture(&block)
    
      html << '<div class="clear"></div></div><div class="b"><div class="b"><div class="b"></div></div></div></div>'
    end.html_safe
  end

  # Render input fields for object CRUD operatins in lists
  def hidden_inputs_for(object, count, options = {})
    
    hide = options[:hide] || []
    more = options[:more] || []
    
    ''.tap do |html|
      html << "<input type=\"hidden\" name=\"edit_#{ count }\" value=\"#{ polymorphic_url([:edit, @container, object ]) }\" ></input>"     unless hide.include?('edit')
      html << "<input type=\"hidden\" name=\"show_#{ count }\" value=\"#{ polymorphic_url([ @container, object ]) }\" ></input>"           unless hide.include?('show')
      html << "<input type=\"hidden\" name=\"delete_#{ count }\" value=\"#{ polymorphic_url([:delete, @container, object ]) }\" ></input>" unless hide.include?('delete')
      html << "<input type=\"hidden\" name=\"notes_#{ count }\" value=\"#{ polymorphic_url([ @container, object, :notes ]) }\" ></input>"  unless hide.include?('notes')
      more.each do |moar_field|
        moar_field.each do |name, url|
          html << "<input type=\"hidden\" name=\"#{ name }_#{ count }\" value=\"#{ url }\" ></input>"
        end
      end
      
    end.html_safe
  end

  def index_actions_for(klass)

    ''.tap do |html|
      
      if klass.name.eql?('Activist')
        if current_user.has_any_permission_to(:leave, Activist)
          html << collection_action_button(klass, 'leave') 
        elsif current_user.has_any_permission_to(:update, Activist)
          html << collection_action_button(klass, 'admin_request') 
        end
      end
      
      if klass.name.eql?('Interested')
        html << interested_collection_action_buttons
      end
      
      klass_name = klass.name
      if klass_name == 'Note'
        klass_name = "#{ @container.class.name }Note"
      end
      if klass < EventRecord
        klass_name = "EventRecord"
      end
      
      { :update => 'edit', :destroy => 'delete' }.each_pair do |action, action_label|
         html << collection_action_button(klass, action_label) if current_user.has_any_permission_to(action, klass_name)
      end

      if current_user.has_any_permission_to(:create, klass_name) and klass_name != 'Alert' 
        html << '<div class="right">'
        html << link_to( t("form.buttons.create"), new_polymorphic_path([ @container, klass.new ], :action => :new), :class => 'action_add with_icon')
        html << '</div>'
      end
      
      if klass.has_fast_search? 
        html << '<div class="fast_search right">'
        html << "<form action=\"#{ polymorphic_url([ @container, klass.new ]) }\" method=\"get\">"
        html << '<input id="query" name="query" type="text" + value = "' + (params[:query]? params[:query] : '') + '" />'
        html << "<input id=\"#{ klass.name.underscore }_submit\" name=\"commit\" type=\"submit\" value=\"#{ t('form.buttons.fast_search') }\" />"
        html << '</form>'
        html << '</div>'
      end
    end
  end

  def collection_action_button(klass, action, options={})

    options[:wrapper_tag] ||= :div
    link = link_to_function(t("form.buttons.#{ action }"),
                                "if(document.indexForm.boxchecked.value == -1) { 
                                  alert('#{ t("form.messages.no_item_selected", :model => Gx.t_model(klass.name))}');
                                } else {
                                  submitform('#{ action }'); }",
                                :class => "action_#{ action } with_icon")

    options[:wrapper_tag].empty? ? link : content_tag(options[:wrapper_tag], link, :class => "actions right")
  end

  def show_actions_for(object)

    ''.tap do |html|
      
      klass_name = object.class.name
      if klass_name == 'Note'
        klass_name = "#{ @container.class.name }Note"
      end
      if object.class < EventRecord
        klass_name = "EventRecord"
      end

      if klass_name.eql?('Activist')
        if object.authorize? :leave, :to => current_user
          html << object_action_button_to(object, 'leave') 
        elsif object.authorize? :update, :to => current_user
          html << object_action_button_to(object, 'admin_request') 
        end
      end
      
      if klass_name.eql?('Interested') 
        html << interested_show_action_buttons(object)
      end

      if klass_name.eql?('Talk') 
        html << print_popup_action_button
      end
      
      { :update => 'edit', :destroy => 'delete' }.each_pair do |action, action_label|
         html << object_action_button_to(object, action_label) if object.authorize? action, :to => current_user
      end

    end
  end

  def object_action_button_to(object, action, options={})
    options[:wrapper_tag] ||= :div
    content_tag options[:wrapper_tag], :class => "actions right" do
      link_to( t("form.buttons.#{action}"), [action, @container, object], :class => "action_#{action} with_icon")
    end
  end

  def print_popup_action_button
    content_tag(:div, :class => "actions right") do
      link_to t("form.buttons.print"), url_for(params.merge({:print_view => true}) ), :class => 'action_print with_icon', :target => "_blank"
    end
  end

  def print_action_bar

    content_tag(:div, :id => 'print_action_bar') do
      link_to_function(t("form.buttons.print"), "window.print();") <<
      link_to_function(t("form.buttons.close"), "window.close();")
    end

  end

  def gx_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    if params[:disabled].present?
      options.merge!( :disabled => params[:disabled] )
    elsif params[:action] == 'show' or ( options[:html] and options[:html][:method] == :delete )
      options.merge!( :disabled => true )
    end
    options.merge!(:action => params[:action])
    Gx.reset_list_style
    form_for(record_or_name_or_array, *(args << options.merge(:builder => ActionView::Helpers::GxFormBuilder)), &proc)
  end

##-----------------------------------------------------
## STATION HELPERS (look for a place for them)

      # Renders notification_area div if there is a flash entry for types: 
      # <tt>:valid</tt>, <tt>:error</tt>, <tt>:warning</tt>, <tt>:info</tt>, <tt>:notice</tt> and <tt>:success</tt>
      def notification_area
        ''.tap do |html|
          html << "<div id='notification_area'>"
          for type in %w{ valid error warning info notice success}
            next if flash[type.to_sym].blank?
            html << "<div class=\"#{ type }\">#{ flash[type.to_sym] }</div>"
          end
          html << "</div>"
        end.html_safe 
      end

end
