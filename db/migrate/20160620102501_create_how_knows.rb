class CreateHowKnows < ActiveRecord::Migration

  def change
  
    create_table :how_knows do |t|
      t.string  :name
      t.timestamps
    end    
    
  end
  
end
