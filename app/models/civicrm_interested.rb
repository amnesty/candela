class CivicrmInterested < ActiveRecord::Base

  attr_accessible :birth_day, :city, :comments, :cp, :email, :first_name, :how_know_id, :last_name, :last_name2, 
                  :local_organization_id, :mobile_phone, :phone, :province_id, :talk_id,
                  :exported_at, :export_errors, :interested_id

  serialize :export_errors

  belongs_to :how_know  
  belongs_to :interested
  
  scope :exported, where('exported_at IS NOT NULL')
  scope :pending, where('exported_at IS NULL')
  scope :with_export_errors, where('export_errors IS NOT NULL')
  
  def self.get_attributes_from_db
    CivicrmInterested.column_names.sort.collect(&:to_sym)
    CivicrmInterested.first.as_json.keys 
  end
  
  def export(options = {})
    options[:verbose] ||= false
    
    if !check_duplicated_interested || !valid_data?
      update_attribute :export_errors, self.errors.as_json
      puts "Input data validation errors creating interested from CiviCRM record ##{self.id}: #{export_errors.inspect}" if options[:verbose]
      return false
    end
    
    straightforward_fields = [
      :first_name, :last_name, :last_name2, :birth_day, :cp, :city, :phone, :mobile_phone, :email, 
      :province_id, :local_organization_id, :how_know_id, :comments,
      ]
    interested_data = self.serializable_hash :only => straightforward_fields      
    interested_data[:talk_ids] = self.talk_id if self.talk_id

    interested = Interested.new(interested_data)
    
    interested.informed_through = InformedThrough.web
    interested.different_residence_country = false
    interested.accepted_privacity = true
    interested.from_civicrm = true
     
    if interested.save  
      if update_attributes(:exported_at => Time.now, :export_errors => nil, :interested_id => interested.id)
        puts "Interested ##{interested.id} created from CiviCRM record ##{self.id}" if options[:verbose]
      else 
        "ERROR: Interested ##{interested.id} created from CiviCRM record ##{self.id}, but the CiviCRM Record could not be updated!!" if options[:verbose]
      end
      
    else    
      update_attribute :export_errors, interested.errors.as_json
      puts "Errors creating interested from CiviCRM record ##{self.id}: #{export_errors.inspect}" if options[:verbose]
    end
    
    interested.valid?
  end

  def check_duplicated_interested
    if self.email && Interested.find_by_email(self.email)
      self.errors.add(:email, :taken )
      begin
        ApplicationMailer.civicrm_duplicated_interested_email(self).deliver 
        update_attribute :duplicated_warning_sent_at, Time.now
      rescue Exception => e       
        self.errors.add(:email, :error_sending_duplicated_interested_email )
      end if duplicated_warning_sent_at.nil?
    end     
  end
  
  
  def valid_data?
    errors.add(:province_id, :does_not_exist) if province_id.present? && !Province.find_by_id(province_id)
    errors.add(:how_know_id, :does_not_exist) if how_know_id.present? && !HowKnow.find_by_id(how_know_id)
    errors.add(:local_organization_id, :does_not_exist) if local_organization_id.present? && !LocalOrganization.find_by_id(local_organization_id)
    errors.add(:talk_id, :does_not_exist) if talk_id.present? && !Talk.find_by_id(talk_id)

    return errors.empty?
  end
  
  def self.export_pending(options = {})
    options[:verbose] ||= false
    puts "No pending records to export" if options[:verbose] && CivicrmInterested.pending.empty?
    CivicrmInterested.pending.each{|ci| ci.export(options) }
  end
  
  def self.clear_associated_interesteds
    CivicrmInterested.all.each {|ci| ci.interested.destroy if ci.interested }
  end
  
  def self.all_export_errors
    CivicrmInterested.with_export_errors.collect{|ci| {:id => ci.id, :errors => ci.export_errors} }
  end
  
end



