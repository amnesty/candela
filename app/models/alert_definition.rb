class AlertDefinition < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :alerts

  # scope :available, { :conditions => [ 'enabled = true AND start_date <= ?', Date.today ] }
  scope :available, { :conditions => [ 'enabled = ?', true ] }

  def self.create_alerts
    AlertDefinition.available.each do |alert_definition|
      puts "Generating alerts for definition named '#{alert_definition.name}'"
      alert_definition.generate_alerts
    end
  end

  def generate_alerts
    
    # We need only ID and watched_field from query objets
    options = { :select => "#{ watched_table }.id, #{ watched_table }.#{ watched_field }" }
    
    options[:conditions] = (watched_where.present? ? watched_where : '') 

    # select only watcheable objects that must be alerted
    options[:conditions] << ' AND ' if options[:conditions].present?
    options[:conditions] << "(#{ watched_table }.created_at > '#{ start_date }') AND "
    options[:conditions] << "(#{ watched_field } >= '#{ Date.today - self.days_for_triggering.days }')"
    
    objects_to_alert      = watched_table.singularize.camelize.constantize.find(:all,  options)
    
    objects_to_alert.each do |object|
      # Unless alerts already create !
      unless self.alerts.find(:first, :conditions => { :record_id => object.id })
         self.alerts.create(:record_id => object.id, :closed => false) && puts("New alert for #{ self.name } to record #{ object.class }##{ object.id }")
       end
    end
    
    return true
  end

  def full_name
    if self.description.blank?
      return self.name
    else
      return self.description
    end
  end

end

