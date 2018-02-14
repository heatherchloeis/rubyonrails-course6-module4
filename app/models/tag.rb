class Tag < ActiveRecord::Base
  include Protectable
  has_many :thing_tags, inverse_of: :tag, dependent: :destroy
  has_many :things, through: :thing_tags
end
