class TwitterNamesController < ApplicationController
  # before_filter :authenticate_user!

  def new
    
  end
  #################################################################
  def create

    #Make a new twittername from the form
    tn = TwitterName.find_by_username(params[:username])

    #Make a temporary User so we have access to those class methods
    @current_user = User.new

    #Specify the TwitterName's attributes
    twitter_client = @current_user.auth_twitter
    if tn
      @curr_tname = tn
      @curr_tname.tweets_collected = params[:tweets_collected]
      @curr_tname.save
    else      
      @curr_tname = TwitterName.new
      @curr_tname.username = params[:username]
      @curr_tname.tweets_collected = params[:tweets_collected]    
      twitter_person = twitter_client.user(@curr_tname.username)
      @curr_tname.twitter_name_id = twitter_person.attrs[:id].to_s
      @curr_tname.save
    end

    #import the requested amount of tweets via the corresponding User class method
    if @curr_tname.tweets_collected == "a few"
    new_tweets = @current_user.get_a_few_twittername_tweets(@curr_tname)
    elsif @curr_tname.tweets_collected == "some"
    new_tweets = @current_user.get_some_twittername_tweets(@curr_tname)
    elsif @curr_tname.tweets_collected == "all"
    new_tweets = @current_user.get_all_twittername_tweets(@curr_tname)
    end

    #Set up a database call to get the links from the tweets
    ntweet_id_array = []
    new_tweets.each do |tweet|
      ntweet_id_array << tweet.twitter_tweet_id
    end

    #Get the links given the tweets
    new_links = Link.where("twitter_tweet_id IN (?)", ntweet_id_array)

        #Maybe we could use hydra here somehow instead of build_attributes
        #     hydra = Typhoeus::Hydra.new(max_concurrency: 20)
        #     new_links.each do |link|
        #     hydra.queue Typhoeus::Request.new("http://api.diffbot.com/v2/article?token=#{ENV['DIFFBOT_TOKEN']}&url=#{link.url}")
        #     end
        #     hydra_array = hydra.run

    #Here we set the domains if we can
    new_links.each do |link|
      link.build_domain
    end

    #Here we schedule the Diffbot lookup (except for during testing)
    unless ENV["RAILS_ENV"] == 'test'
      new_links.each do |link|
        link.build_attributes
      end
    end

    #Want to be able to call rake tasks
    require 'rake'
    @rake_app = Rake.application
    @rake_app.init
    # do this as many times as needed
    @rake_app.add_import 'lib/tasks/db.rake'
    # this loads the Rakefile and other imports
    @rake_app.load_rakefile

    #Here we tell rake to run the scheduler job
    @rake_app['jobs:work'].invoke
    redirect_to twitter_names_path
  end
  #################################################################
  def index
    @twitternames = TwitterName.all
  end
  #################################################################
  def show
    @data = get_all_tweet_info_for_table(params[:id])
    @domain_counts = get_domain_info_for_table_columns(@data.keys) #this method takes just the tweets
  end
end
