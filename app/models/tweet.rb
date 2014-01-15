class Tweet < ActiveRecord::Base
  attr_accessible :url, :tweet_date, :twitter_name_id, :twitter_tweet_id, :domain
  validates :twitter_tweet_id, uniqueness: true

  def build_domain 
    unless self.domain
      self.domain = URI.parse(self.url).host      
      self.save
    end
  end 

end
