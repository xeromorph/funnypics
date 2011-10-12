class Image < ActiveRecord::Base
  attr_accessible :description, :img
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  attr_writer :tag_names
  #before_save :assign_tags
  before_validation :assign_tags
  attr_protected :img_size, :img_file_name, :img_content_type
  has_attached_file :img, :styles => { :thumb => ["150x150>", :jpg] },
                          #:url  => "/assets/images/:id/:style/:basename.:extension",
                          :hash_data => ":class/:attachment/:id",
                          :url  => "/assets/:class/:style/:hash.:extension",
                          :path => ":rails_root/public/assets/images/:style/:hash.:extension"

  validates_presence_of :description
#  validates_presence_of :tags
  validates_attachment_presence :img
  validates_attachment_size :img, :less_than => 10.megabytes
  validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/x-png', 'image/gif']
  
  def tag_names
    @tag_names || tags.map(&:name).join(', ')
  end

  def next(tagname)
    if tagname.present?
      Image.where(["tags.name IS ? and images.id > ?",tagname,self.id]).find(:first, :include => :tags, :order => 'images.id ASC') || Image.where(["tags.name IS ?",tagname]).find(:first, :include => :tags, :order => 'images.id ASC')
    else
      Image.where(["images.id > ?",self.id]).find(:first, :order => 'images.id ASC') || Image.find(:first, :order => 'images.id ASC')
    end
  end
  
  def prev(tagname)
    if tagname.present?
      Image.where(["tags.name IS ? and images.id < ?",tagname,self.id]).find(:last, :include => :tags, :order => 'images.id ASC') || Image.where(["tags.name IS ?",tagname]).find(:last, :include => :tags, :order => 'images.id ASC')
    else
      Image.where(["images.id < ?",self.id]).find(:last, :order => 'images.id ASC') || Image.find(:last, :order => 'images.id ASC')
    end
  end

  private
  def assign_tags
    self.tags = @tag_names.strip.downcase.split(/\s*,\s*/).map do |tname|
      Tag.find_or_initialize_by_name(tname) if tname.present?
    end
    errors[:base] << "at least one tag must be specified" unless self.tags.any? 
  end
end
