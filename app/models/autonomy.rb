class Autonomy < ActiveRecord::Base
  
  attr_accessible :name, :collaborations_enabled, :phone, :address, :cp, :province_id, :city, :email, :email_2, :fax, 
                  :customer_service_time, :meeting_weekday, :meeting_frequency, :meeting_hours, :meeting_venue, 
                  :postal_address, :postal_cp, :postal_province_id, :postal_city, 
                  :delivery_contact, :delivery_phone, :delivery_hours, :delivery_address, :delivery_cp, :delivery_province_id, :delivery_city,
                  :autonomic_team_ids

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::AIOrganization
  include MailTemplateConsumer

  has_many :campaignactions, :as => :organization, :dependent => :destroy
  has_many :talks, :foreign_key => :organization_id, :conditions => "organization_type = 'Autonomy'", :dependent => :destroy
  has_many :autonomic_teams, :dependent => :destroy
  
  def full_name; name; end

  def to_title;
    "#{ I18n.t("autonomy.abrev") }: #{ full_name }";
  end
  
#  def check_campaigns
#    if self.campaignactions.any?
#      self.errors.add :base, :has_campaignactions
#      return false
#    end
#  end

  #OPTIMIZE: Maybe this method should be in AIOrganization...
  def active_members_with_responsibility(responsibility_name)
    resp = Responsibility.find_by_name(responsibility_name) 
    managers = activists_collaborations.collect {|c| c.activist if (c.has_responsibility?(resp) && c.is_active && c.is_member) }.compact
  end

end

