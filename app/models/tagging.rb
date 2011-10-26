class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => "images_count"
  belongs_to :image
end
