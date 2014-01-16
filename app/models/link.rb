class Link < ActiveRecord::Base
  attr_accessible :author, :authored_date, :domain, :title, :twitter_tweet_id, :kind_of_url, :url, :tweet_id
  validates :url, uniqueness: true

  #Here I use the default key unlike for usernames, because tweet IDs arent special
  belongs_to :tweet

  def build_attributes
    unless self.domain
      self.domain = URI.parse(self.url).host
      self.save
    end
    social_domains = ["app.strava.com","4sq.com", "yfrog.com", "fb.me", "i.imgur.com", "imgur.com", "instagr.am", "Instagram.com", "instagram.com", "kck.st", "livestream.com", "linkd.in", "lnkd.in", "lockerz.com", "path.com", "pinterest.com", "qr.ae", "songza.com", "spoti.fi", "tinyurl.com", "tumblr.com", "tmblr.co","twitpic.com", "twitter.com", "www.eventbrite.com", "www.facebook.com", "www.giltcity.com", "www.grouponworks.com", "www.groupon.com", "www.linkedin.com", "www.quora.com", "youtu.be", "www.youtube.com"]
    if social_domains.include?(self.domain)
      self.kind_of_url = "social"
    elsif self.author == nil || self.authored_date == nil || self.title == nil || self.kind_of_url == nil
      json = HTTParty.get("http://api.diffbot.com/v2/article?token=#{ENV['DIFFBOT_TOKEN']}&url=#{self.url}")
      self.author = json["author"]
      self.authored_date = json["date"]
      #convert the date
      self.authored_date ? self.authored_date.strftime("%m/%d/%Y") : nil
      self.title = json["title"]
      self.kind_of_url = json["type"]
    end
    #lots more
  end
end

