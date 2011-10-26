class AddImagesCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :images_count, :integer, :default => 0

    Tag.reset_column_information
    Tag.all.each do |p|
      Tag.update_counters p.id, :images_count => p.images.length
    end
  end

  def self.down
    remove_column :tags, :images_count
  end
end
