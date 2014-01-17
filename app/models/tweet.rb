class Tweet < ActiveRecord::Base
  attr_accessible :url, :tweet_date, :twitter_name_id, :twitter_tweet_id, :domain, :text
  validates :twitter_tweet_id, uniqueness: true

  ##Twitter has its own ID field which is useful because it persists even if the user 
  ##changes their username (not uncommon), so I use that:
  belongs_to :twitter_names, :foreign_key => :twitter_name_id
  has_many :links, :foreign_key => :twitter_tweet_id.to_s
  # has_many :links

#MAY NOT NEED THE METHOD BELOW1
  def build_domain 
    unless self.domain
      self.domain = URI.parse(self.url).host      
      self.save
    end
  end 

end
