class CustomActionTopic < ActiveRecord::Base
  attr_accessible :name, :requires_extra_fields

  has_and_belongs_to_many :performed_actions

end
