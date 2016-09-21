class AddDuplicatedWarningSentAtToCivicrmInteresteds < ActiveRecord::Migration
  def change
    add_column :civicrm_interesteds, :duplicated_warning_sent_at, :datetime
  end
end
