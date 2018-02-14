FactoryGirl.define do

  factory :tag do
  	keyword {Faker::Commerce.product_name}
  	creator_id 1

  	trait :with_keyword do
  	  keyword {Faker::Commerce.product_name}
  	end
  end
end
