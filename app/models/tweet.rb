class Tweet < ActiveRecord::Base
  attr_accessible :url, :tweet_date, :twitter_name_id, :twitter_tweet_id, :domain
  validates :twitter_tweet_id, uniqueness: true

  def initialize(options)
    @url = options[:url] 
    @tweet_date = options[:tweet_date] 
    @twitter_tweet_id = options[:twitter_tweet_id]
    @twitter_name_id = options[:twitter_name_id]
    @domain = URI.parse(@url).host
  end
end
