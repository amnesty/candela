class MailTemplateCollectionsController < ApplicationController
  include ActionController::AIController

# TODO: add permissions for mail template collections
#  authorization_filter :create, :mail_template_collection, :only => [ :new, :create ]
#  authorization_filter :read,   :mail_template_collectio, :only => [ :show, :index ]
#  authorization_filter :update, :mail_template_collectio, :only => [ :edit, :update]
#  authorization_filter :destroy, :mail_template_collectio, :only => [ :delete, :destroy ]
  
#  def index
#    @collections = MailTemplateCollection.all
#  end
  
end
