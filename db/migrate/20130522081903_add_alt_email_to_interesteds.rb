class AddAltEmailToInteresteds < ActiveRecord::Migration
  def change
    add_column :interesteds, :email_2, :string
  end
end
