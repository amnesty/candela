module ActivistsHelper
  
  def collaboration_row(activist, collaboration)
    if  collaboration.authorize?(:read, :to => current_agent)
      text = collaboration.is_member ? "member_collaborations_for_activist" : "other_collaborations_for_activist" 
      t( "activists_collaboration.texts.#{ text }", 
          :collaboration_type => link_to(h(collaboration.kind),activist_activists_collaboration_path(collaboration.activist, collaboration)),
          :organization       => link_to(h(collaboration.organization.name), collaboration_organization_path(collaboration)),
          :join_at            => localize(collaboration.join_at.to_date),
          :responsibility     => collaboration.h_responsibilities )
    end.html_safe
  end
end


