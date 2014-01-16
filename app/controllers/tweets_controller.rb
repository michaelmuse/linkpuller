class TweetsController < ApplicationController
  def index
    @data = get_all_tweet_info_for_table(nil) #nil means we dont have a specific twittername
    @domain_counts = get_domain_info_for_table_columns(@data.keys) #this method takes just the tweets
  end
end