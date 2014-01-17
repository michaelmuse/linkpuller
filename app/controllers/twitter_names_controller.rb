class TwitterNamesController < ApplicationController
  before_filter :authenticate_user!

  def new
    
  end
  def create

    #make a new twittername from the form
    @new_tname = TwitterName.new
    @new_tname.username = params[:username]
    @new_tname.tweets_collected = params[:tweets_collected]    
    #make a temporary User so we have access to those class methods
    @current_user = User.new
    twitter_client = @current_user.auth_twitter
    twitter_person = twitter_client.user(@new_tname.username)
    @new_tname.twitter_name_id = twitter_person.attrs[:id].to_s
    @new_tname.save
    #import the requested amount of tweets via the corresponding User class method
    if @new_tname.tweets_collected == "a few"
    new_tweets = @current_user.get_a_few_twittername_tweets(@new_tname)
    elsif @new_tname.tweets_collected == "some"
    new_tweets = @current_user.get_some_twittername_tweets(@new_tname)
    elsif @new_tname.tweets_collected == "all"
    new_tweets = @current_user.get_all_twittername_tweets(@new_tname)
    end
    ntweet_id_array = []
    new_tweets.each do |tweet|
      ntweet_id_array << tweet.twitter_tweet_id
    end
    new_links = Link.where("twitter_tweet_id IN (?)", ntweet_id_array)
#Maybe we could use hydra here somehow instead of build_attributes
#     hydra = Typhoeus::Hydra.new(max_concurrency: 20)
#     new_links.each do |link|
#     hydra.queue Typhoeus::Request.new("http://api.diffbot.com/v2/article?token=#{ENV['DIFFBOT_TOKEN']}&url=#{link.url}")
#     end
#     hydra_array = hydra.run
    new_links.each do |link|
      link.build_attributes
    end
    redirect_to twitter_names_path
  end

  def index
    @twitternames = TwitterName.all
  end

  def show
    @data = get_all_tweet_info_for_table(params[:id])
    @domain_counts = get_domain_info_for_table_columns(@data.keys) #this method takes just the tweets
  end
end
