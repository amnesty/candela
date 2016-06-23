class AddImageToActivists < ActiveRecord::Migration
  def change
    add_attachment :activists, :image  
  end
end
