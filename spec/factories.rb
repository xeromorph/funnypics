include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :image do
    description "Some valid non-empty descrition"
    #img fixture_file_upload(Rails.root + 'spec/factories/valid_image.png','image/png')
    img { File.open(File.join(Rails.root + 'spec','factories','valid_image.png')) }
    tag_names "few, valid, tags"
  end
end
