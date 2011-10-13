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
  
  #scopes
  scope :recent, order("images.created_at desc")

  def tag_names
    @tag_names || tags.map(&:name).join(', ')
  end

  def next(tagname = nil)
    @next = Image.recent
    if tagname
      @next = @next.includes(:tags).where("tags.name = ?",tagname)
    end
    @next.where("images.created_at < ?",self.created_at).first || @next.first
  end
  
  def prev(tagname = nil)
    @prev = Image.recent
    if tagname
      @prev = @prev.includes(:tags).where("tags.name = ?",tagname)
    end
    @prev.where("images.created_at > ?",self.created_at).last || @prev.last
  end

  private
  def assign_tags
    self.tags = @tag_names.strip.downcase.split(/\s*,\s*/).map do |tname|
      Tag.find_or_initialize_by_name(tname) if tname.present?
    end
    errors[:base] << "at least one tag must be specified" unless self.tags.any? 
  end
end
