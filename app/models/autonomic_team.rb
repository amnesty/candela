class AutonomicTeam < ActiveRecord::Base

  include ActiveRecord::AIActiveRecord

  attr_accessible :name, :autonomy_id

  belongs_to :autonomy
  has_and_belongs_to_many :activists_collaborations

  def to_title; name; end
  def self.has_fast_search?; false; end

  def full_name
    "#{autonomy.name} - #{name}"    
  end

  # Authorization delegated to autonomy
  authorizing do |user, permission|
    self.autonomy.authorize? permission, :to => user unless self.autonomy.nil?
  end
  
end
