class CreateCivicrmInteresteds < ActiveRecord::Migration
  def change
    
    create_table :civicrm_interesteds do |t|
      
      t.string  :first_name
      t.string  :last_name
      t.string  :last_name2
      t.date    :birth_day
      t.integer :province_id
      t.string  :cp,           :limit => 5
      t.string  :city
      t.string  :phone,        :limit => 12
      t.string  :mobile_phone, :limit => 12
      t.string  :email
      
      t.integer :local_organization_id
      t.integer :talk_id

      t.integer :country_id
      
      t.string  :how_know_id
      t.text    :comments

      t.integer :interested_id
      t.date    :exported_at
      t.text    :export_errors
      
      t.timestamps
    end
    
    add_column :interesteds, :how_know_id, :integer
    add_column :interesteds, :comments, :text
    
  end
end
