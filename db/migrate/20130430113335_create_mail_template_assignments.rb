class CreateMailTemplateAssignments < ActiveRecord::Migration
  def change
    create_table :mail_template_assignments do |t|
      t.string :consumer_type
      t.integer :consumer_id
      t.integer :mail_template_collection_id
      t.string :template_name

      t.timestamps
    end
  end
end
