class ActivistsCollaborationsResponsibility < ActiveRecord::Base
  
  belongs_to :activists_collaboration
  belongs_to :responsibility

end