class TwitterName < ActiveRecord::Base
  attr_accessible :twitter_name_id, :username
  validates :twitter_name_id, uniqueness: true
end
