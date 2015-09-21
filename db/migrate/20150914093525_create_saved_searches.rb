class CreateSavedSearches < ActiveRecord::Migration
  def change
    create_table :saved_searches do |t|
      t.string  :name
      t.integer :user_id
      t.text    :target
      t.text    :params
      
      t.timestamps
    end
  end
end
