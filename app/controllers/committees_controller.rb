class CommitteesController < ApplicationController
  include ActionController::AIOrganizationController

  authorization_filter :create, :committee,  :only => [ :new, :create     ]
  # Organizations can be listed for all.
  # authorization_filter :read,   :committee,  :only => [ :show, :index     ]
  authorization_filter :update, :committee,  :only => [ :edit, :update    ]
  authorization_filter :destroy, :committee, :only => [ :delete, :destroy ]

  before_filter :set_enable, :only => [ :create ]
  
  private
  def set_enable
    @committee.enabled = true
  end

end
