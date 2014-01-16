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
  RubyProf.start
    if tweets != nil
      tweets.each do |tweet|
        begin 
          curr_url = tweet.uris.first.attrs
        rescue 
        end
        if curr_url 
          #Store a new tweet
          t = Tweet.new
          t.twitter_tweet_id = tweet.attrs[:id].to_s
          t.url = curr_url[:expanded_url]
          t.build_domain
          t.tweet_date = tweet.attrs[:created_at]
          t.twitter_name_id = tweet.attrs[:user][:id].to_s
          t.text = tweet.attrs[:text]
          t.save
          #Store a new TwitterName
          tn = TwitterName.new
          tn.twitter_name_id = tweet.attrs[:user][:id].to_s #if this already exists, the user is not remade
          tn.username = tweet.attrs[:user][:screen_name]
          tn.save
          #Store a new link
          l = Link.new(url: t.url)
          l.tweet_id = t.id
          l.build_attributes
          l.twitter_tweet_id = t.twitter_tweet_id
          l.save
        end
      end
    end
  result = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT)
  end

  def get_a_few_twittername_tweets_helper(twittername, client)
  #HERE WE PULL IN A SMALL AMOUNT OF TWEETS PROVIDED A TWITTERNAME OBJECT HASNT ALREADY RUN THIS QUERY
    begin
    current_tn_in_db_before_action = TwitterName.find(twittername.twitter_name_id)
    rescue
    end
    unless current_tn_in_db_before_action && Tweet.where(twitter_name_id: twittername.twitter_name_id).count > 30
      options = {
        exclude_replies: true,
        include_rts: false,
        count: 30,
      }

      tweets = client.user_timeline(twittername.username, options) 

    end      

  end

  def get_some_twittername_tweets_helper(twittername, client)
  #HERE WE PULL IN A SMALL AMOUNT OF TWEETS PROVIDED A TWITTERNAME OBJECT HASNT ALREADY RUN THIS QUERY
    begin
    current_tn_in_db_before_action = TwitterName.find(twittername.twitter_name_id)
    rescue
    end
    unless current_tn_in_db_before_action && Tweet.where(twitter_name_id: twittername.twitter_name_id).count > 200
      options = {
        exclude_replies: true,
        include_rts: false,
        count: 200,
      }

      tweets = client.user_timeline(twittername.username, options) 

    end      

  end

  def get_all_twittername_tweets_helper(twittername, client)
    begin
    current_tn_in_db_before_action = TwitterName.find(twittername.twitter_name_id)
    rescue
    end
    unless current_tn_in_db_before_action && Tweet.where(twitter_name_id: twittername.twitter_name_id) > 1000
      def collect_with_max_id(collection=[], max_id=nil, &block)
        response = yield max_id
        collection += response
        response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
      end

      def get_all_tweets(user, client)
        collect_with_max_id do |max_id|
          options = {:count => 200, :include_rts => true}
          options[:max_id] = max_id unless max_id.nil?
          client.user_timeline(user, options)
        end
      end

      #HERE WE PULL IN ALL TWEETS (warning) FROM A USER PROVIDED WE DONT ALREADY HAVE THEM
      tweets = get_all_tweets(twittername.username, client)
    end
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

  def get_a_few_twittername_tweets(twittername)
    client = auth_twitter
    tweets = get_a_few_twittername_tweets_helper(twittername, client)
    save_tweets(tweets)
  end

end

