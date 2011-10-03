class Image < ActiveRecord::Base
  attr_accessible :description, :img
  attr_protected :img_size, :img_file_name, :img_content_type
  has_attached_file :img, :styles => { :thumb => ["150x150>", :jpg] },
                          #:url  => "/assets/images/:id/:style/:basename.:extension",
                          :hash_data => ":attachment",
                          :url  => "/assets/:class/:style/:hash.:extension",
                          :path => ":rails_root/public/assets/images/:style/:hash.:extension"

  validates_presence_of :description
  validates_attachment_presence :img
  validates_attachment_size :img, :less_than => 10.megabytes
  validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/png', 'image/gif']
end
