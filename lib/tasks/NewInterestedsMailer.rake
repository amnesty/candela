namespace :new_interested do
  namespace :mailer do
    
    desc "Send daily email to LocalOrganization with information of new interesteds"
    task :send_daily => :environment do

      get_new_interesteds_from_yesterday = Interested.find(:all, :conditions => ['created_at >= ? AND created_at < ?', Time.now.yesterday.beginning_of_day, Time.now.beginning_of_day ])
      local_organizations = get_new_interesteds_from_yesterday.map(&:local_organization).uniq

      local_organizations.each do |lo|
        interesteds = get_new_interesteds_from_yesterday.select{|it| it.local_organization_id == lo.id }
        ApplicationMailer.resume_alert_email(lo, interesteds).deliver if interesteds.any?
      end
    end

    desc "Send weekly email to LocalOrganization with information of new interesteds. Run"
    task :send_weekly => :environment do

      get_new_interesteds_from_last_week = Interested.find(:all, :conditions => ['created_at >= ? AND created_at < ?', Time.now.yesterday.beginning_of_week, Time.now.yesterday.end_of_week ])
      local_organizations = get_new_interesteds_from_last_week.map(&:local_organization).uniq

      local_organizations.each do |lo|
        interesteds = get_new_interesteds_from_last_week.select{|it| it.local_organization_id == lo.id }
        ApplicationMailer.resume_alert_email(lo, interesteds).deliver if interesteds.any?
      end

    end
  end
end
