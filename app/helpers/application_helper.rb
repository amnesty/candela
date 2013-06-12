module ApplicationHelper

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
        html << action_button_to(klass, 'leave')
      end
      
      if klass.name.eql?('Interested')
        html << action_button_to(klass, 'to_activist')
        html << action_button_to(klass, 'prepare_mail') if current_user.has_any_permission_to(:create_email, :interesteds, :on => Site.current)
        html << action_button_to(klass, 'prepare_pdf')  if current_user.has_any_permission_to(:create_pdf,   :interesteds, :on => Site.current)
      end
      
      
      klass_name = klass.name
      if klass_name == 'Note'
        klass_name = "#{ @container.class.name }Note"
      end
      
      { :update => 'edit', :destroy => 'delete' }.each_pair do |action, action_label|
         html << action_button_to(klass, action_label) if current_user.has_any_permission_to(action, klass_name)
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

  def action_button_to(klass, action)

    ''.tap do |html|
      html << "<div class=\"actions right\">"
      html << link_to_function(t("form.buttons.#{ action }"),
                                "if(document.indexForm.boxchecked.value == -1) { 
                                  alert('#{ t("form.messages.select_item_to_#{ action }", :model => t("activerecord.models.#{ klass.name.downcase.gsub("_", " ") }"))}');
                                } else {
                                  submitform('#{ action }'); }",
                                :class => "action_#{ action } with_icon")
      html << "</div>"
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
