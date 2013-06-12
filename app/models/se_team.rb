# encoding: utf-8
class SeTeam < ActiveRecord::Base

  attr_accessible :name, :collaborations_enabled, :phone, :address, :cp, :province_id, :city, :email, :email_2, :fax, 
                  :customer_service_time, :meeting_weekday, :meeting_frequency, :meeting_hours, :meeting_venue, 
                  :postal_address, :postal_cp, :postal_province_id, :postal_city, 
                  :delivery_contact, :delivery_phone, :delivery_hours, :delivery_address, :delivery_cp, :delivery_province_id, :delivery_city

  include ActiveRecord::AIActiveRecord
  include ActiveRecord::AIOrganization

  scope :available_for_hr_schools, { :conditions => {:name => "Educación en DDHH"} }

  def full_name
    I18n.t('se_team.full_name', :name => self.name)
  end
  
  def to_title
    full_name
  end



end


