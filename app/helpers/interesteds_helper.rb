module InterestedsHelper

  def interested_collection_action_buttons
    ''.tap do |html|
        html << "<ul id='interested_communications_buttons' class='actions right'><li>"
        html << collection_action_button(Interested, 'communications', :wrapper_tag => '')
        html << "<ul>"
        html << collection_action_button(Interested, 'prepare_mail', :wrapper_tag => :li) #if current_user.has_any_permission_to(:create_email, :interesteds, :on => Site.current)
        html << collection_action_button(Interested, 'prepare_pdf', :wrapper_tag => :li) # if current_user.has_any_permission_to(:create_pdf,   :interesteds, :on => Site.current)
        html << collection_action_button(Interested, 'not_interested', :wrapper_tag => :li) # if current_user.has_any_permission_to(:update,   :interesteds, :on => Site.current)
        html << collection_action_button(Interested, 'new_communication', :wrapper_tag => :li) # if current_user.has_any_permission_to(:update,   :interesteds, :on => Site.current)
        html << '</ul></li>'
        html << "</ul>"
        html << collection_action_button(Interested, 'to_activist') # if current_user.has_any_permission_to(:create, :activists, :on => Site.current) 
    end
  end

  def interested_show_action_buttons(interested)
    ''.tap do |html|
        if interested.activist.present?
          html << content_tag(:div, :class => "actions right"){link_to( t("form.buttons.show_activist"), interested.activist, :class => "action_show_activist with_icon")} if current_user.has_any_permission_to(:read, :activists, :on => Site.current) 
        else
          html << "<ul id='interested_communications_buttons' class='actions right'><li>"
          html << link_to( t("form.buttons.communications"), interested_interested_communications_path(interested), :class => "action_communications with_icon")
          html << "<ul>"
          html << object_action_button_to(interested, 'prepare_mail', :wrapper_tag => :li) if interested.authorize?(:update, :to => current_user)
          html << object_action_button_to(interested, 'prepare_pdf', :wrapper_tag => :li) if interested.authorize?(:update, :to => current_user)
          html << object_action_button_to(interested, 'not_interested', :wrapper_tag => :li) if interested.authorize?(:update, :to => current_user)
          html << button_to_new_communication(interested) if interested.authorize?(:update, :to => current_user)
          html << '</ul></li>'
          html << "</ul>"
          html << object_action_button_to(interested, 'to_activist') if interested.authorize?(:update, :to => current_user)
          html << print_popup_action_button
      end
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

  def previous_history_events_for(interested)
    events = []
    events << {:date => l(interested.created_at.to_date), :info => link_to(t('interested.previous_history_events.registered'), interested)}
    interested.communications.each{|c| events << {:date => l(c.timestamp.to_date), :info => h(c.communication_description)} }
    interested.talk_attendances.each {|talk_attendace| events << {
      :date => l(talk_attendace.talk.date.to_date), 
      :info => link_to(t('interested.previous_history_events.talk'), talk_path(talk_attendace.talk)) + "  " +  content_tag(:span, "(#{talk_attendace.h_status})", :class => "talk_attendance_status_#{talk_attendace.status}")
      }}
    events << {:date => l(interested.activist.created_at.to_date), :info => link_to(t('interested.previous_history_events.migrated'), interested.activist )} if interested.activist.present?

    events
    #events.collect{|item| content_tag :li, "#{item[:date]}: #{item[:info]}".html_safe}.join.html_safe
  end
  
end


