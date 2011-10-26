class AddImgToImages < ActiveRecord::Migration
  def change
    add_column :images, :img, :string
  end
end
