class CleanResponsibilityFields < ActiveRecord::Migration
  def up
    remove_column :responsibilities, :for_member
    remove_column :responsibilities, :for_autonomy
  end

  def down
    add_column :responsibilities, :for_member, :boolean
    add_column :responsibilities, :for_autonomy, :boolean
  end
end
