class AddNotInterestedFieldsToInteresteds < ActiveRecord::Migration
  def change
    add_column :interesteds, :not_interested_at, :datetime
    add_column :interesteds, :not_interested_info, :text    
  end
end
