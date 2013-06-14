class CreateAutonomicTeams < ActiveRecord::Migration
  def change

    create_table :autonomic_teams do |t|
      t.string :name
      t.integer :autonomy_id
      t.timestamps
    end
    add_index :autonomic_teams, :autonomy_id

    create_table :activists_collaborations_autonomic_teams, :id => false, :force => true do |t|
      t.string :activists_collaboration_id
      t.integer :autonomic_team_id
    end

  end
end
