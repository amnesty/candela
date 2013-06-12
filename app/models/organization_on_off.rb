# encoding: utf-8
class OrganizationOnOff < ActiveRecord::Base
  include ActiveRecord::AIActiveRecord
  
  attr_accessible :organization_id, :organization_type, :on_or_off, :date, :more_info

  belongs_to :organization, :polymorphic => true

  scope :order_by_date, { :order => [ 'date ASC' ] }

  validates_presence_of :date
  validate :check_date

  after_save  :act_org_active
  acts_as_content :reflection => :organization
  
  def self.has_fast_search?; false; end

  # authorizing though organization
  authorizing do |user, permission|
    organization.authorize?(permission, :to => user) || nil
  end
  
  
  def is_active?
    if on_or_off.nil?
      true
    else
      on_or_off == "on"
    end
  end


  def check_date
    if self.respond_to?(:new_record)
      last_signonoff = organization.organization_on_offs.order_by_date.find(:last)
      if !last_signonoff.nil?
        if self.date < last_signonoff.date
          errors.add(:date, :invalid_date)
          return false
        end
      end
    end
  end


  # Set the status of the organization to active or inactive
  def act_org_active
    if organization.organization_on_offs.any?
      last_date = organization.organization_on_offs.order_by_date.find(:last)
      if last_date.nil?
        organization.enabled = true
      else # toggle enabled
        organization.enabled = last_date.is_active?
      end
    else
      organization.enabled = true
    end
    organization.save(:validation => false)
  end

  def h
    # FIXME
    if self.date.nil?
      "Activa (fecha desconocida)"
    elsif is_active?
      "Activa el día #{I18n.localize(self.date)}"
    else
      "Inactiva el día #{I18n.localize(self.date)}"
    end
  end
  
  def to_title
    self.organization.name
  end

end
