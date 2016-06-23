class FixIdCivicrmField < ActiveRecord::Migration
  def change
    remove_column :activists, :id_civicrm
    add_column :civicrm_interesteds, :civicrm_contact_id, :integer
  end

end
