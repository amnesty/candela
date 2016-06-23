class AddIdCivicrmToCivicrmActivists < ActiveRecord::Migration
  def change
    add_column :activists, :id_civicrm, :integer
  end
end
