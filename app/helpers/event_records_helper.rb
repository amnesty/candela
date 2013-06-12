module EventRecordsHelper

  def extra_info_for_event(ev)
    case ev

      when ActivistStatusChange
        I18n.t 'activist_status_change.texts.full_description', 
          :date => I18n.localize(ev.date.to_date), 
          :activist_name => link_to( ev.activist.full_name, ev.activist),
          :status_change_name => ev.activist_status.name, 
          :collaboration_type => link_to( ev.activists_collaboration.kind, ev.activists_collaboration),
          :organization => link_to( ev.activists_collaboration.organization_name, ev.activists_collaboration.organization)

      when InterestedCommunication
        I18n.t 'interested_communication.texts.full_description', 
          :date => I18n.localize(ev.created_at.to_date), 
          :interested_name => link_to( ev.interested.full_name, ev.interested),
          :communication_description => ev.communication_description

      else
  
        if ev.event_definition.codename.eql?('interested_to_activist')
          activist = Activist.find_by_id ev.info["activist_id"] || Activist.new(:name => '<eliminado>')
          I18n.t 'event_record.texts.full_description.interested_to_activist',
            :date => I18n.localize(ev.created_at.to_date), 
            :interested_description => link_to( ev.h_record, ev.event_object ),
            :activist_description => link_to( activist.full_name, activist )
        
        elsif ['activist_note_created','activist_note_updated'].include? ev.event_definition.codename
          activist = ev.event_object.noteable
          I18n.t "event_record.texts.full_description.#{ev.event_definition.codename}",
            :date => I18n.localize(ev.created_at.to_date), 
            :activist_description => link_to( activist.full_name, activist )
        
        else
          I18n.t 'event_record.texts.full_description.default',
            :date => I18n.localize(ev.created_at.to_date), 
            :object_description => link_to( ev.h_record, ev.event_object )
        end
    end

  end 

end
