class NotesController < ApplicationController
  
  include ActionController::AIController
  
 
  before_filter :container_to_object
  before_filter :set_parents
  
  authorization_filter :create,  :note, :only => [ :new, :create ]
  authorization_filter :read,    :note, :only => [ :show, :index ]
  authorization_filter :update,  :note, :only => [ :edit, :update]
  authorization_filter :destroy, :note, :only => [ :delete, :destroy ]
  
  before_filter :check_note_to_inactive_activist
  
  def create_with_success
    polymorphic_url(@container, :anchor => "#{ @container.class.name.underscore }_section_notes")
  end
  
  def update_with_success
    polymorphic_url([ @container ], :anchor => "#{ @container.class.name.underscore }_section_notes")
  end
  
  private
  def container_to_object
    if @note
      @note.container = current_container
    else
      params[:note].delete("#{ current_container.class.name.underscore }_id") if params[:note]
      @note     = current_container.notes.new(params[:note])
      @resource = @note
    end
  end
  
  def set_parents
    if params[:parent_id]
      parent_note   = Note.find(params[:parent_id])
      @note.parents = "#{ parent_note.parents }#{ parent_note.id }/"
    end
  end
  
  def check_note_to_inactive_activist
    if @note.container.is_a?(Activist) and @note.container.has_no_active_collaborations
      redirect_to @note.container, :flash => { :error => t('activist.cant_use_activist_due_no_collaborations') }
    end
  end

end