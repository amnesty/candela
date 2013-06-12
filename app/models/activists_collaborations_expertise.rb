class ActivistsCollaborationsExpertise < ActiveRecord::Base
  
  belongs_to :activists_collaboration
  belongs_to :expertises

end