module NotesHelper
 
  # recursive order a collection through has_many :childs model relation and parents named scope, used for example, on notes views or comments
  #
  # class Comment
  #   has_many :childs, :class_name => 'Comments', :foreing_key => :parent_id
  #   named_scope :parents, { :conditions => 'parent_id IS NULL'}
  # end
  #
  # ordered_comments = recursive_ordered_collection(Comment.parents.all)
  #
  # return an ordered array of hashes with deep and item keys
  #
  # Gnoxys tricks http://www.gnoxys.net. Feel free to use || copy || modify
  def threaded_notes_for_parent(note, &block)
    thread = note.thread
    notes  = recursive_ordered_collection(note.direct_descendants(thread), thread)
    if block.present?
      yield notes
    end
    notes
  end
  
  def recursive_ordered_collection(descendants, thread, ordered_array = [], deep = 1)
    descendants.each do |item|
      item.deep = deep
      ordered_array << item
      if item.direct_descendants(thread).any?
        ordered_array = ordered_array | recursive_ordered_collection(item.direct_descendants(thread), thread, ordered_array, deep + 1)
      end
    end
    ordered_array
  end
  
  def notes_parents_view(parent_notes)

    ''.tap do |html|
      parent_notes.each do |parent_note|

        html << '<div class="parent_note">'
        html << note_view(parent_note)
        html << '<ul class="child_notes">'

        threaded_notes_for_parent(parent_note).each do |child_note|
          html << "<li style=\"margin-left: #{ 10 * child_note.deep }px;\">"
          html << note_view(child_note)
          html << "</li>"
        end
        
        html << '</ul>'
        html << '</div>'
      end
    end.html_safe
  end
  
  def note_view(note)
    ''.tap do |html|
      html << "<span>#{ note.title }</span>"
      html << "<p>#{ note.body }</p>"
      

      html << "<p class=\"meta\">"
      html << t('note.meta', :author => note.h_author, :datetime => localize(note.created_at, :format => :short))
      
      if note.cache_permission_to_replay(current_agent)
        html << ". #{ link_to(t('note.reply'), new_polymorphic_url([note.noteable, Note.new], :parent_id => note.id)) }"
      end 
      if note.cache_permission_to_edit(current_agent)
        html << ". #{ link_to(t('note.edit'), edit_polymorphic_url([note.noteable, note])) }"
      end 
      
      html << "</p>"
    end
  end
end
