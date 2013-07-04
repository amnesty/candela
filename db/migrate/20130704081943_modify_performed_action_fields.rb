class ModifyPerformedActionFields < ActiveRecord::Migration

  def up

    add_column :performed_actions, :mobilization_pre, :boolean
    add_column :performed_actions, :mobilization_pre_description, :text
    add_column :performed_actions, :mobilization_tour, :boolean
    add_column :performed_actions, :mobilization_tour_description, :text

    add_column :performed_actions, :used_material_evaluation, :text
    add_column :performed_actions, :used_material_others, :boolean
    add_column :performed_actions, :used_material_others_description, :text

    add_column :performed_actions, :activists_raising_expert, :boolean

    add_column :performed_actions, :gender_approach_applied, :boolean

    Campaignaction.all.each do |c|    
      c.update_attribute(:institutional_authorities_contact, c.institutional_authorities_contact + '\n' + c.institutional_other) if !c.institutional_other.blank?
      c.update_attribute :gender_approach_applied, c.gender_approach
    end

    remove_column :performed_actions, :institutional_other
    remove_column :performed_actions, :media_other

  end

  def down

    remove_column :performed_actions, :mobilization_pre
    remove_column :performed_actions, :mobilization_pre_description
    remove_column :performed_actions, :mobilization_tour
    remove_column :performed_actions, :mobilization_tour_description

    remove_column :performed_actions, :used_material_evaluation
    remove_column :performed_actions, :used_material_others
    remove_column :performed_actions, :used_material_others_description

    remove_column :performed_actions, :activists_raising_expert

    remove_column :performed_actions, :gender_approach_applied

    add_column :performed_actions, :institutional_other, :text
    add_column :performed_actions, :media_other, :text

  end

end
