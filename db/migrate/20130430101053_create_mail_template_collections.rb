class CreateMailTemplateCollections < ActiveRecord::Migration
  def change
    create_table :mail_template_collections do |t|
      t.string :codename
      t.text :description
      t.text :default_template_name
      t.text :available_consumers_script

      t.timestamps
    end
  end
end
