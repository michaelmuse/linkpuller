class TwitterName < ActiveRecord::Base
  attr_accessible :twitter_name_id, :username, :tweets_collected
  validates :twitter_name_id, uniqueness: true

  ##Twitter has its own ID field which is useful because it persists even if the user 
  ##changes their username (not uncommon), so I use that:
  has_many :tweets, :foreign_key => :twitter_name_id ##<--THIS doesnt seem to work

end
