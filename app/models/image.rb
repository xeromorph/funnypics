class Image < ActiveRecord::Base
  attr_accessible :description, :img
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  attr_writer :tag_names
  before_save :assign_tags
  attr_protected :img_size, :img_file_name, :img_content_type
  has_attached_file :img, :styles => { :thumb => ["150x150>", :jpg] },
                          #:url  => "/assets/images/:id/:style/:basename.:extension",
                          :hash_data => ":class/:attachment/:id",
                          :url  => "/assets/:class/:style/:hash.:extension",
                          :path => ":rails_root/public/assets/images/:style/:hash.:extension"

  validates_presence_of :description
  validates_attachment_presence :img
  validates_attachment_size :img, :less_than => 10.megabytes
  validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/x-png', 'image/gif']
  
  def tag_names
    @tag_names || tags.map(&:name).join(', ')
  end

  def next
    Image.first(:conditions => ['id > ?', self.id], :order => 'id ASC') || Image.first
  end
  
  def prev
    Image.last(:conditions => ['id < ?', self.id], :order => 'id ASC') || Image.last
  end

  private
  def assign_tags
    if @tag_names
      self.tags = @tag_names.split(/,\s*/).map do |tname|
        Tag.find_or_initialize_by_name(tname)
      end
    end
  end
end
