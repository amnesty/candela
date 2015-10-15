class AddGroupTypeToLocalOrganizations < ActiveRecord::Migration
  def up
    add_column :local_organizations, :group_type, :string, :null => false, :default => 'local'
    LocalOrganization.reset_column_information     
    LocalOrganization.all.select{|o|o.name.underscore.include? 'univ'}.each{|o| o.update_attribute :group_type, 'universitary'}
  end
  
  def down
    remove_column :local_organizations, :group_type
  end
  
end
