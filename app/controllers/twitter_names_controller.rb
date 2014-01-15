class TwitterNamesController < ApplicationController

  def new
    
  end
  def create
    #make a new twittername from the form
    @new_tname = TwitterName.new
    @new_tname.username = params[:username]
    @new_tname.tweets_collected = params[:tweets_collected]    
    #make a temporary User so we have access to those class methods
    @curr_user = User.new() #probably should get current from sessions?
    #make a twitter client so I can lookup the twitter_user_id
    twitter_client = @curr_user.auth_twitter
    twitter_person = twitter_client.user(@new_tname.username)
    @new_tname.twitter_name_id = twitter_person.attrs[:id]
    @new_tname.save
    #import the requested amount of tweets via the corresponding User class method
    if @new_tname.tweets_collected == "some"
    @curr_user.get_some_twittername_tweets(@new_tname)
    elsif @new_tname.tweets_collected == "all"
    @curr_user.get_all_twittername_tweets(@new_tname)
    end
    redirect_to twitter_names_path
  end

  def index
    @twitternames = TwitterName.all
  end

  def show
    @username = TwitterName.find(params[:id])
    @username_tweets = Tweet.where(twitter_name_id: @username.twitter_name_id)
  end
end
