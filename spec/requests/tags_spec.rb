require 'rails_helper'

RSpec.describe "Tags", type: :request do
  include_context "db_cleanup"
  let(:account) {signup FactoryGirl.attributes_for(:user)}

  context "quick API check" do
  	let!(:user) {login account}
  	it_should_behave_like "resource index", :tag
  	it_should_behave_like "show resource", :tag
  	it_should_behave_like "create resource", :tag
  	it_should_behave_like "modifiable resource", :tag
  end
end
