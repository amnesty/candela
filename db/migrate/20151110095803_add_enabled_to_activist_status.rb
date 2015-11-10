class AddEnabledToActivistStatus < ActiveRecord::Migration
  def change
    add_column :activist_statuses, :enabled, :boolean, :default => true    
    ActivistStatus.reset_column_information    
    ActivistStatus.where(:id => [ActivistStatus.inactive_id,ActivistStatus.leave_proposed_id]).each{|s|s.update_attribute :enabled, false }    
  end
end
