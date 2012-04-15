class Image < ActiveRecord::Base
  attr_accessible :description, :img, :tag_names
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  attr_accessor :tag_names
  before_validation :assign_tags
  #before_validation :assign_checksum
  #attr_protected :img_size, :img_file_name, :img_content_type

  mount_uploader :img, ImageUploader
  #has_attached_file :img, :styles => { :thumb => ["150x150>", :jpg] },
  #                        :hash_data => ":class/:attachment/:id",
  #                        :url  => "/assets/:class/:style/:hash.:extension",
  #                        :path => ":rails_root/public/assets/images/:style/:hash.:extension"
  #validates_uniqueness_of :checksum
  validates_presence_of :img
  validates_presence_of :description
  validate :img_uniqueness, :on => :create
  #validates_attachment_presence :img
  #validates_attachment_size :img, :less_than => 10.megabytes
  #validates_attachment_content_type :img, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/x-png', 'image/gif']
  
  #scopes
  scope :recent, order("images.created_at desc")
  scope :tagged, lambda { |tag| includes(:tags).where("tags.name = ?",tag) }
  scope :before, lambda { |time| where("images.created_at < ?",time) }
  scope :after, lambda { |time| where("images.created_at > ?",time) }

  #per_page
  #self.per_page = 5
  paginates_per 5

  def tag_names
    @tag_names || self.tags.map(&:name).join(', ')
  end

  def next(tagname = nil)
    @next = Image.recent
    if tagname
      @next = @next.tagged(tagname)
    end
    @next.before(self.created_at).first || @next.first
  end
  
  def prev(tagname = nil)
    @prev = Image.recent
    if tagname
      @prev = @prev.tagged(tagname)
    end
    @prev.after(self.created_at).last || @prev.last
  end

  private

#  def assign_checksum
#    self.checksum = img.md5 if img.present? and img_changed?
#  end

  def assign_tags
    self.tags = tag_names.strip.downcase.split(/\s*,\s*/).map do |tname|
      Tag.find_or_initialize_by_name(tname) if tname.present?
    end
    errors[:base] << "at least one tag must be specified" unless self.tags.any? 
  end

  def img_uniqueness
    errors.add :img, "Image already exists in database" if self.img.present? and Image.where(Image.arel_table[:img].matches("%#{self.img.md5}%")).any?
  end
end
