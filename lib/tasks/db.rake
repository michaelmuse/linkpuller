namespace :db do
  desc "Seed my database"
  task :seed => :environment do
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

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

    @tweets.each do |tweet|
      curr_url = tweet.uris.first.attrs
      unless curr_url == []
        t = Tweet.new
        tn = TwitterName.new
        t.twitter_tweet_id = tweet.attrs[:id]
        t.url = curr_url[:expanded_url]
        t.tweet_date = tweet.attrs[:created_at]
        t.twitter_name_id = tweet.attrs[:user][:id]
        t.text = tweet.attrs[:text]
        tn.twitter_name_id = tweet.attrs[:user][:id]
        tn.username = tweet.attrs[:user][:screen_name]
        t.save
        tn.save
      end
    end
  end

  desc "Seed my database a little bit"
  task :seed_small => :environment do
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    #HERE WE PULL IN A SMALL AMOUNT OF TWEETS FROM ME
    options = {
      exclude_replies: true,
      include_rts: false,
      count: 200,
    }
    @tweets = @client.user_timeline("michaelmuse", options) 

    @tweets.each do |tweet|
      begin 
        curr_url = tweet.uris.first.attrs
      rescue 
      end
      if curr_url 
        t = Tweet.new
        tn = TwitterName.new
        t.twitter_tweet_id = tweet.attrs[:id]
        t.url = curr_url[:expanded_url]
        t.build_domain
        t.tweet_date = tweet.attrs[:created_at]
        t.twitter_name_id = tweet.attrs[:user][:id]
        t.text = tweet.attrs[:text]
        tn.twitter_name_id = tweet.attrs[:user][:id]
        tn.username = tweet.attrs[:user][:screen_name]
        t.save
        tn.save
      end
    end
  end


  desc "clear the databse"
  task :clear => :environment do
    Tweet.delete_all
    TwitterName.delete_all
  end

end
