
require 'spec_helper'

describe Image do

  describe 'responds to attributes' do
    subject { Image.new }
    
    it { should respond_to :img }
    it { should respond_to :description }
    it { should respond_to :tag_names }
    #it { should have_many :tags }
    #it { should have_many :taggings }
  end

  describe 'is valid with given valid attributes' do
    subject { FactoryGirl.build(:image) }

    it { should be_valid }
  end
end
