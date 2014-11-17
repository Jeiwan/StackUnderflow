# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do
    file { File.new("#{Rails.root}/spec/features/user/new_avatar.jpg") }
    #file "some file"
    association :attachable
  end
end
