class AddIdToInterestedsTalks < ActiveRecord::Migration
  def change
    add_column :interesteds_talks, :id, :primary_key
  end
end
