class DeviseMigrateUsers < ActiveRecord::Migration
  def up
    # MIGRATE STATION USERS TO DEVISE
    OldUser.find(:all).each do |u|
      def_password = Devise.friendly_token.first(8)
      user = User.create :id => u.id, :login => u.login, :email => u.email, :password => def_password, :password_confirmation => def_password
      user.update_attribute :created_at, u.created_at
      user.update_attribute :updated_at, u.updated_at
    end
    puts "[WARNING] Some users have not been migrated!!" unless OldUser.all.count == User.all.count
  end

  def down
  end

end
