class ExpandCampaignactions < ActiveRecord::Migration
  def change

    create_table :custom_action_topics do |t|
      t.string :name, :null => false
      t.boolean :requires_extra_fields, :default => false
      t.timestamps
    end

    rename_table :campaignactions, :performed_actions
    add_column :performed_actions, :type, :string
    add_column :performed_actions, :custom_name, :string
    add_column :performed_actions, :custom_action_topic_id, :integer
    add_column :performed_actions, :custom_action_topic_other, :string
    add_index :performed_actions, :custom_action_topic_id

    create_table :custom_action_topics_performed_actions, :id => false do |t|
      t.integer :custom_action_topic_id
      t.integer :performed_action_id
    end

  end
end
