class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

    def auth_twitter
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
  def save_tweets(tweets)
    tweets.each do |tweet|
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

  def get_some_twittername_tweets_helper(twittername, client)
  #HERE WE PULL IN A SMALL AMOUNT OF TWEETS PROVIDED A TWITTERNAME OBJECT
    options = {
      exclude_replies: true,
      include_rts: false,
      count: 200,
    }
    tweets = client.user_timeline(twittername.username, options)       
  end

  def get_all_twittername_tweets_helper(twittername, client)
    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield max_id
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    def get_all_tweets(user)
      collect_with_max_id do |max_id|
        options = {:count => 200, :include_rts => true}
        options[:max_id] = max_id unless max_id.nil?
        client.user_timeline(user, options)
      end
    end

    #HERE WE PULL IN ALL TWEETS (warning) FROM A USER
    tweets = get_all_tweets(twittername.username)
  end

  def get_all_twittername_tweets(twittername)
    client = auth_twitter
    tweets = get_all_twittername_tweets_helper(twittername, client)
    save_tweets(tweets)
  end

  def get_some_twittername_tweets(twittername)
    client = auth_twitter
    tweets = get_some_twittername_tweets_helper(twittername, client)
    save_tweets(tweets)
  end


end

