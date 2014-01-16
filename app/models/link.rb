class Link < ActiveRecord::Base
  attr_accessible :author, :authored_date, :domain, :title, :twitter_tweet_id, :url_type, :url
  validates :url, uniqueness: true

  def build_attributes
    unless self.domain
      self.domain = URI.parse(self.url).host
      self.save
    end
    #lots more
  end
end
