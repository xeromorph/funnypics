class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :images, :through => :taggings
end
