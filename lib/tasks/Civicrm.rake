# encoding: utf-8
namespace :civicrm do
  namespace :interesteds do
    
    desc "Export pending CiviCRM interesteds to Candela"
    task :export => :environment do
      CivicrmInterested.export_pending(:verbose => true)
    end

  end
end
