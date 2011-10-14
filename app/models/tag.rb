class Tag < ActiveRecord::Base
  attr_accessible :name
  has_many :taggings, :dependent => :destroy
  has_many :images, :through => :taggings
 
  validates :name, :presence => true,
                   :uniqueness => { :case_sensitive => false}
end
