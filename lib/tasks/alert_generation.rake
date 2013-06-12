namespace :alerts do

  namespace :generate do    
    desc "Generate all pending Alerts"
    task :pending => :environment do
      AlertDefinition.create_alerts
    end
  end

  namespace :remove do
    desc "Remove old alerts"
    task :old => :environment do
      # Gets alerts closed and not updated in 3 months
      alerts = Alert.find(:all, :conditions => [ 'closed = 1 and updated_at < ?', Time.now - Alert::DELETE_AFTER])
      alerts.each do |a|
        puts "Deleting old alert #{ a.id } which is closed and last updated at #{ a.updated_at }"
        puts a.destroy ? 'done' : 'fail'
      end
    end
  end
end
