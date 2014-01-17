namespace :db do

  desc "Authenticate Twitter"
  task :auth_twitter => :environment do
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
  desc "Save data to db"
  task :save_tweets => :environment do

    @tweets.each do |tweet|
      begin 
        curr_url = tweet.uris.first.attrs
      rescue 
      end
      if curr_url 
        t = Tweet.new
        tn = TwitterName.new
        t.twitter_tweet_id = tweet.attrs[:id].to_s
        t.url = curr_url[:expanded_url]
        t.build_domain
        t.tweet_date = tweet.attrs[:created_at]
        t.twitter_name_id = tweet.attrs[:user][:id].to_s
        t.text = tweet.attrs[:text]
        tn.twitter_name_id = tweet.attrs[:user][:id].to_s
        tn.username = tweet.attrs[:user][:screen_name]
        t.save
        tn.save
      end
    end

  end

  desc "Small Seed helper"
  task :seed_small_helper => :environment do
    #HERE WE PULL IN A SMALL AMOUNT OF TWEETS FROM ME
    options = {
      exclude_replies: true,
      include_rts: false,
      count: 200,
    }
    @tweets = @client.user_timeline("jbloomgarden", options) 
  end

  desc "Large Seed helper"
  task :seed_helper => :environment do
    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield max_id
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    def get_all_tweets(user)
      collect_with_max_id do |max_id|
        options = {:count => 200, :include_rts => true}
        options[:max_id] = max_id unless max_id.nil?
        @client.user_timeline(user, options)
      end
    end

    #HERE WE PULL IN ALL TWEETS (LOTS) FROM MARK SUSTER
    @tweets = get_all_tweets("msuster")

  end


  desc "Seed my database"
  task :seed => [:auth_twitter, :seed_helper, :save_tweets] do
    puts "Tweets collected"
  end

  desc "Seed my database a little bit"
  task :seed_small => [:auth_twitter, :seed_small_helper, :save_tweets] do
    puts "Tweets collected"
  end

  desc "clear the databse"
  task :clear => :environment do
    Tweet.delete_all
    TwitterName.delete_all
  end

  desc "enrich plain links"
  task :enrich_links => :environment do
    links = Link.all
    @social_domains = ["app.strava.com","4sq.com", "yfrog.com", "fb.me", "i.imgur.com", "imgur.com", "instagr.am", "Instagram.com", "instagram.com", "kck.st", "livestream.com", "linkd.in", "lnkd.in", "lockerz.com", "path.com", "pinterest.com", "qr.ae", "songza.com", "spoti.fi", "tinyurl.com", "tumblr.com", "tmblr.co","twitpic.com", "twitter.com", "www.eventbrite.com", "www.facebook.com", "www.giltcity.com", "www.grouponworks.com", "www.groupon.com", "www.linkedin.com", "www.quora.com", "youtu.be", "www.youtube.com"] 
    links.each do |link|
      if @social_domains.include?(link.domain)
        link.kind_of_url = "social"
      elsif link.author == nil && link.authored_date == nil && link.title == nil && link.kind_of_url == nil
        json = HTTParty.get("http://api.diffbot.com/v2/article?token=#{ENV['DIFFBOT_TOKEN']}&url=#{link.url}")
        link.author = json["author"]
        link.authored_date = json["date"]
        #convert the date
        link.authored_date ? link.authored_date.strftime("%m/%d/%Y") : nil
        link.title = json["title"]
        link.kind_of_url = json["type"]
        link.save
      end
    end
  end
end