require 'rails_helper'

RSpec.describe "Tags", type: :model do
  include_context "db_cleanup"

  context "build valid tag" do
  	it "default tag created with random keyword" do
  	  tag=FactoryGirl.build(:tag)
  	  expect(tag.creator_id).to_not be_nil
  	  expect(tag.save).to be true
  	end

  	it "tag with User and non-nil keyword" do
  	  user=FactoryGirl.create(:user)
  	  tag=FactoryGirl.build(:tag, :with_keyword, :creator_id=>user.id)
  	  expect(tag.creator_id).to eq(user.id)
  	  expect(tag.keyword).to_not be_nil
  	  expect(tag.save).to be true
  	end
  end
end