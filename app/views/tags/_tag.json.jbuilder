json.extract! tag, :id, :keyword, :creator_id, :created_at, :updated_at
json.url tag_url(tag, format: :json)
json.user_roles tag.user_roles	unless tag.user_roles.empty?