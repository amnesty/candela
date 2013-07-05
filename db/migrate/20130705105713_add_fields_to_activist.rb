class AddFieldsToActivist < ActiveRecord::Migration
  def change
    add_column :activists, :dedication_hours, :string
    add_column :activists, :in_person_collaboration, :boolean
    add_column :activists, :remote_collaboration, :boolean
  end
end
