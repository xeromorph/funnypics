
require 'spec_helper'

describe Image do

  describe 'responds to attributes' do
  #  subject { Image.new }
  #  
    it { should respond_to :img }
    it { should respond_to :description }
    it { should respond_to :tag_names }
    it { should have_many :tags }
    it { should have_many :taggings }
  end

  describe 'is valid with given valid attributes' do
    subject { build(:image) }

    it { should be_valid }
  end
  context 'is invalid' do
    describe 'with empty description' do
      subject { build(:image, description: "") }

      it { should_not be_valid }
    end

    describe 'without img' do
      subject { build(:image, img: {}) }

      it { should_not be_valid }
    end
    
    describe 'without tags' do
      subject { build(:image, tag_names: nil) }

      it { should_not be_valid }
    end
    describe 'with image already in database' do
      before { create(:image) }
      specify { build(:image).should_not be_valid }
    end
  end
end
