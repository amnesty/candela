module ActivistsCollaborationsHelper
  
  #OPTIMIZE: status_options_for_select AND type_options_for_select created becuase with rails 2.3.8 seems to have no possibility of including classes in options_for_select. It Rails is updated, optimize these methods!
  def status_options_for_select(default_value = 'status_3')
    option_list = ActivistStatus.all.collect{|elem| [elem.name, "status_#{ elem.id }", :class => "collaboration_status_#{ elem.id }"] } 
    option_list.prepend ['Todos los estados','', :class => '']
    select_tag('collaboration_status[]', options_for_select(option_list), {:id => 'activist_filter_status', :onchange => "modifyActivistFilter('status',$(this))" } )

  end


  def type_options_for_select(uniq_name, default_value = '')
    option_list = ActivistsCollaboration.organization_collaboration_types.collect {|k| [t("#{ uniq_name }.sections.#{ k }_collaborations"), k, :class => "collaboration_type_#{ k }"] }
    option_list.prepend [t("#{ uniq_name }.sections.all_collaborations"),'', :class => '']
    select_tag('collaboration_type[]', options_for_select(option_list), {:id => 'activist_filter_type', :onchange => "modifyActivistFilter('type',$(this))" } )

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
