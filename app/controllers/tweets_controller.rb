class TweetsController < ApplicationController
#NEED to not do this if they are signed in, fix in twitternames controller too  # before_filter :authenticate_user!

  def index
    @data = get_all_tweet_info_for_table(nil) #nil means we dont have a specific twittername
    @domain_counts = get_domain_info_for_table_columns(@data.keys) #this method takes just the tweets
  end
end