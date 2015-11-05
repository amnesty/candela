module ActivistsCollaborationsHelper
 
  def options_for_autonomic_teams(autonomy, selected = nil) 
    options = (autonomy.nil? ? [[t('activists_collaboration.select_an_autonomy'),'']] : autonomy.autonomic_teams.collect{|team|[team.name,team.id]} )
    options_for_select(options, selected)
  end
 
  def status_options_for_select(default_value = 'status_not_leave')
    option_list = ActivistStatus.all.collect{|elem| [elem.name, "status_#{ elem.id }", :class => "collaboration_status_#{ elem.id }"] } 
    option_list.prepend [Gx.proper(t 'activists_collaboration.texts.status_not_leave'),'status_not_leave', :class => '']
    option_list.prepend [Gx.proper(t 'activists_collaboration.texts.all_statuses'),'', :class => '']
    select_tag('collaboration_status[]', options_for_select(option_list, :selected => default_value), {:id => 'activist_filter_status', :onchange => "modifyActivistFilter('status',$(this))" } )

  end


  def type_options_for_select(uniq_name, default_value = '')
    option_list = ActivistsCollaboration.organization_collaboration_types.collect {|k| [t("#{ uniq_name }.sections.#{ k }_collaborations"), k, :class => "collaboration_type_#{ k }"] }
    option_list.prepend [t("#{ uniq_name }.sections.all_collaborations"),'', :class => '']
    select_tag('collaboration_type[]', options_for_select(option_list), {:id => 'activist_filter_type', :onchange => "modifyActivistFilter('type',$(this))" } )

  end

  def responsibility_options_for_select(default_value = '')
    option_list = Responsibility.order(:name).collect{|elem| [elem.name, "responsibility_#{ elem.id }"] } 
    option_list.prepend [Gx.proper(t 'activists_collaboration.texts.all_responsibilities'),'', :class => '']
    select_tag('collaboration_responsibility[]', options_for_select(option_list), {:id => 'activist_filter_responsibility', :onchange => "modifyActivistFilter('responsibility',$(this))" } )
  end
  
  def autonomic_team_options_for_select(autonomy, default_value = '')
    default_value = "autonomic_team_#{default_value.id}" if default_value.is_a?(AutonomicTeam)
    option_list = autonomy.autonomic_teams.collect {|team| [team.name, "autonomic_team_#{team.id}", :class => "autonomic_team_#{ team.id }"] }
    option_list.prepend [t("autonomy.sections.all_autonomic_teams"),'', :class => '']
    select_tag('autonomic_team[]', options_for_select(option_list, default_value), {:id => 'activist_filter_autonomic_team', :onchange => "modifyActivistFilter('autonomic_team',$(this))" } )
  end

  def display_activist_collaborations_marks(collaboration)
    status_css   = "collaboration_status_#{ collaboration.activist_status_id ? collaboration.activist_status_id : 'status_undefined' }"
    status_title ="#{ collaboration.activist_status_id ? collaboration.activist_status.name : t('activists_collaboration.unknown_status') }"
    marks = %( <span title="#{ status_title }" class="collaboration_mark #{ status_css }"></span> )
    used_classes = [ 'member', 'support', 'casual', 'expertise' ]
    used_classes.each do |css_class|
      if collaboration.send("is_#{ css_class }")
        marks << %( <span title="#{ t("activists_collaboration.#{ collaboration.collaboration_type }") }" class="collaboration_mark collaboration_type_#{ css_class }"></span> )
      end
    end
    marks
  end



  def collaboration_organization_path(collaboration)
    case collaboration.organization_type
    when 'LocalOrganization'
      return local_organization_path(collaboration.organization_id)
    when 'SeTeam'
      return se_team_path(collaboration.organization_id)
    when 'Autonomy'
      return autonomy_path(collaboration.organization_id)
    when 'Country'
      return country_path(collaboration.organization_id)
    when 'Committee'
      return committee_path(collaboration.organization_id)
    when 'Expertise'
      return expertise_path(collaboration.organization_id)
    end
  end

end
