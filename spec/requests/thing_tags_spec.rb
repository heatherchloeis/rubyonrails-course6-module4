require 'rails_helper'

RSpec.describe "ThingTags", type: :request do
  include_context "db_cleanup_each"
  let(:account) {signup FactoryGirl.attributes_for(:user)}
  let!(:user) {login account}

  describe "manage thing/tag relationships" do
    context "valid thing and tag" do
      let(:thing) { create_resource(things_path, :thing, :created) }
      let(:tag)   { create_resource(tags_path, :tag, :created) }
      let(:thing_tag_props) { 
        FactoryGirl.attributes_for(:thing_tag, :tag_id=>tag["id"]) 
      }

      it "can associate tag with thing" do
        #associated the tag to the Thing
        jpost thing_thing_tags_path(thing["id"]), thing_tag_props
        expect(response).to have_http_status(:no_content)

        #get Thingtags for Thing and verify associated with tag
        jget thing_thing_tags_path(thing["id"])
        expect(response).to have_http_status(:ok)
        #puts response.body
        payload=parsed_body
        expect(payload.size).to eq(1)
        expect(payload[0]).to include("tag_id"=>tag["id"])
        expect(payload[0]).to include("tag_keyword"=>tag["keyword"])
      end

      it "must have tag" do
        jpost thing_thing_tags_path(thing["id"]), 
              thing_tag_props.except(:tag_id)
        expect(response).to have_http_status(:bad_request)
        payload=parsed_body
        expect(payload).to include("errors")
        expect(payload["errors"]["full_messages"]).to include(/param/,/missing/)
      end
    end
  end
  shared_examples "can get links" do
    it "can get links for Thing" do
      jget thing_thing_tags_path(thing["id"])
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(tags.count)
      expect(parsed_body[0]).to include("tag_keyword")
      expect(parsed_body[0]).to_not include("thing_name")
    end
    it "can get links for Tag" do
      jget tag_thing_tags_path(tags[0]["id"])
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body[0]).to_not include("tag_keyword")
      expect(parsed_body[0]).to include("thing_name"=>thing["name"])
    end
  end
  shared_examples "get linkables" do |count|
    it "return linkable things" do
      jget tag_linkable_tag_things_path(tags[0]["id"])
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(count)
      if (count > 0)
          parsed_body.each do |thing|
            expect(thing["id"]).to be_in(unlinked_things.map{|t|t["id"]})
            expect(thing).to include("description")
            expect(thing).to include("notes")
          end
      end
    end
  end
  shared_examples "can create link" do
    it "link from Thing to Tag" do
      jpost thing_thing_tags_path(thing["id"]), thing_tag_props
      expect(response).to have_http_status(:no_content)
      jget thing_thing_tags_path(thing["id"])
      expect(parsed_body.size).to eq(tags.count+1)
    end
    it "link from Tag to Thing" do
      jpost tag_thing_tags_path(thing_tag_props[:tag_id]), 
                                    thing_tag_props.merge(:thing_id=>thing["id"])
      expect(response).to have_http_status(:no_content)
      jget thing_thing_tags_path(thing["id"])
      expect(parsed_body.size).to eq(tags.count+1)
    end
    it "bad request when link to unknown tag" do
      jpost thing_thing_tags_path(thing["id"]), 
                                    thing_tag_props.merge(:tag_id=>99999)
      expect(response).to have_http_status(:bad_request)
    end
    it "bad request when link to unknown Thing" do
      jpost tag_thing_tags_path(thing_tag_props[:tag_id]), 
                                    thing_tag_props.merge(:thing_id=>99999)
      expect(response).to have_http_status(:bad_request)
    end
  end
  shared_examples "can delete link" do
    it do
      jdelete thing_thing_tag_path(thing_tag["thing_id"], thing_tag["id"])
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "cannot create link" do |status|
    it do
      jpost thing_thing_tags_path(thing["id"]), thing_tag_props
      expect(response).to have_http_status(status)
    end
  end
  shared_examples "cannot delete link" do |status|
    it do
      jdelete thing_thing_tag_path(thing_tag["thing_id"], thing_tag["id"])
      expect(response).to have_http_status(status)
    end
  end

  describe "ThingTag Authn policies" do
    let(:account)         { signup FactoryGirl.attributes_for(:user) }
    let(:thing_tag)       { #return existing thing so we can modify
      jget thing_thing_tags_path()
      expect(response).to have_http_status(:ok)
      parsed_body[0]
    }
      let(:tags) {(1..3).map {create_resource(tags_path, :tag, :created)}}
      let!(:unlinked_things) {(1..2).map {create_resource(things_path, :thing, :created)}}
      let(:orphan_tag) {FactoryGirl.create(:tag)}
      let(:thing_tag_props) {{:tag_id=>orphan_tag.id}}

      before(:each) do
        tags.map do |tag|
          jpost thing_thing_tags_path(thing["id"]), {:tag_id=>tag["id"]}
          expect(response).to have_http_status(:no_content)
        end
      end

    context "user is anonymous" do
      before(:each) { logout }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2
      it_should_behave_like "cannot create link", :unauthorized
      it_should_behave_like "cannot delete link", :unauthorized
    end
    context "user is authenticated" do
      before(:each) { login account }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2
      it_should_behave_like "cannot create link", :forbidden
      it_should_behave_like "cannot delete link", :forbidden
    end
  #   context "user is member" do
  #     before(:each) do
  #       login apply_member(account, things) 
  #     end
  #     it_should_behave_like "can get links"
  #     it_should_behave_like "get linkables", 2, [Role::MEMBER]
  #     it_should_behave_like "can create link"
  #     it_should_behave_like "cannot delete link", :forbidden
  #   end
  #   context "user is organizer" do
  #     it_should_behave_like "can get links"
  #     it_should_behave_like "get linkables", 2, [Role::ORGANIZER]
  #     it_should_behave_like "can create link"
  #     it_should_behave_like "can delete link"
  #   end
  #   context "user is admin" do
  #     before(:each) { login apply_admin(account) }
  #     it_should_behave_like "can get links"
  #     it_should_behave_like "get linkables", 0
  #     it_should_behave_like "cannot create link", :forbidden
  #     it_should_behave_like "can delete link"
  #   end
  end
end