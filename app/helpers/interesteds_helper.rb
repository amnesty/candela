module InterestedsHelper

  def interested_action_buttons(interested)
    ''.tap do |html|
        if interested.activist.present?
          html << content_tag(:div, :class => "actions right"){link_to( t("form.buttons.show_activist"), interested.activist, :class => "action_show_activist with_icon")} if current_user.has_any_permission_to(:read, :activists, :on => Site.current) 
        else
          html << "<ul id='interested_communications_buttons' class='actions right'><li>"
          html << link_to( t("form.buttons.communications"), interested_interested_communications_path(interested), :class => "action_communications with_icon")
          html << "<ul>"
          html << interested_communication_button_to(interested, 'prepare_mail') if current_user.has_any_permission_to(:create_email, :interesteds, :on => Site.current)
          html << interested_communication_button_to(interested, 'prepare_pdf')  if current_user.has_any_permission_to(:create_pdf,   :interesteds, :on => Site.current)
          html << button_to_new_communication(interested) if current_user.has_any_permission_to(:update,   :interesteds, :on => Site.current)
          html << '</ul></li>'
          html << "</ul>"
          html << object_action_button_to(interested, 'to_activist') if current_user.has_any_permission_to(:update, :interesteds, :on => Site.current) 
      end
    end
  end

  def interested_communication_button_to(interested, action)
    content_tag :li, :class => "actions right" do
      link_to( t("form.buttons.#{action}"), [action, @container, interested], :class => "action_#{action} with_icon")
    end
  end

  def button_to_new_communication(interested)
    action = 'new_communication'
    new_communication = interested.communications.new
    interested.communications.delete new_communication
    content_tag :li, :class => "actions right" do
      link_to( t("form.buttons.#{action}"), new_polymorphic_url([ interested, new_communication ]), :class => "action_#{action} with_icon")
    end
  end

end


