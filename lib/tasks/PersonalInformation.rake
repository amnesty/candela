# encoding: utf-8
namespace :personal_information do
  namespace :clean do
    
    desc "Cleaning sensitive information"
    task :sensitive_information => :environment do
      remove_time       = Time.now - Activist::REMOVE_DATA_AFTER
      set_to_leave_time = Time.now - Activist::SET_TO_LEAVE_AFTER


      activists = Activist.all
      activists.each do |activist|

        # Clean activists with leave_at date minor than #{ I18n.localize(remove_time.to_date) }"
        if !activist.leave_at.nil? 
          if activist.mobile_phone == '999999999'
            puts "Activist ##{ activist.id } -> Already cleaned (leave at #{activist.leave_at})"
          elsif activist.leave_at < remove_time
            puts "!!Activist ##{ activist.id } -> Cleaning activist (leave at #{activist.leave_at})"
            activist.clear_sensitive_data
            activist.save(:validate => false)
          else
            puts "Activist ##{ activist.id } -> Not cleaning yet (leave at #{activist.leave_at})"
          end

        # Set leave to activists with no collaborations or no active collaborations and time has exceed
        elsif activist.has_no_active_collaborations or activist.activists_collaborations.count.zero?
          if activist.reference_time_for_leave < set_to_leave_time
            puts "!!Activist ##{ activist.id } -> Leaved due to more than #{Activist::SET_TO_LEAVE_AFTER.inspect} without active_collaborations (last update at #{activist.reference_time_for_leave})"
            activist.leave_at = Time.now
            activist.leave_reason_id = 1
            activist.leave_more_info = 'El activista lleva más del tiempo especificado sin colaboración activa'
            activist.save(:validate => false)
          else
            puts "Activist ##{ activist.id } -> Inactive, but not leaving yet (last update at #{activist.reference_time_for_leave})"
          end
        else
          puts "Activist ##{ activist.id } -> Nothing to do"
        end
      end

      puts "Getting interesteds with created_at date minor than #{ I18n.localize(remove_time.to_date) }"
      interesteds = Interested.find(:all, :conditions => [ "created_at < ? AND mobile_phone !=  999999999" , remove_time ])
      interesteds.each do |i|
        i.clear_sensitive_data
        i.save(:validate => false)
        puts "cleaned #{ i.first_name }"
      end
    end

  end
end
