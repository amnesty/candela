module SavedSearchesHelper

  def saved_search_collection_action_buttons
    ''.tap do |html|
      html << collection_action_button(SavedSearch, 'load', :link_class => 'action_search with_icon') 
      html << collection_action_button(SavedSearch, 'edit') 
      html << collection_action_button(SavedSearch, 'delete') 
    end
  end

  def saved_search_show_action_buttons(saved_search)
    ''.tap do |html|
      html << object_action_button_to(saved_search, 'load', :link_class => 'action_search with_icon') 
    end
  end

end


