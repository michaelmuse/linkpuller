class Tweet < ActiveRecord::Base
  attr_accessible :url, :tweet_date, :twitter_name_id, :twitter_tweet_id, :domain
  validates :twitter_tweet_id, uniqueness: true
end
