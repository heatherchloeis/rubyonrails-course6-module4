class ThingTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :thing

  validates :tag, :thing, presence: true

  scope :with_thing, ->{ joins("left outer join things on things.id = thing_tags.thing_id")
                         	 .select("thing_tags.*")}
  scope :with_tag, 	 ->{ joins("right outer join tags on tags.id = thing_tags.tag_id")
                         	 .select("thing_tags.*","tags.id as tag_id")}

  scope :with_name,    ->{ with_thing.select("things.name as thing_name")}
  scope :with_keyword, ->{ with_tag.select("tags.keyword as tag_keyword")}
end