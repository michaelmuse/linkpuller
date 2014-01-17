class ApplicationController < ActionController::Base
  protect_from_forgery

  def get_all_tweet_info_for_table(tname_id)
    if tname_id
    username = TwitterName.find(tname_id)
    tweets = Tweet.where(twitter_name_id: username.twitter_name_id).order(:domain)
    else
    tweets = Tweet.find(:all, :order => :domain)
    end
    data = {}
    tweets.each do |tweet|
      uNameAndLinks = []
      uNameAndLinks << username
      uNameAndLinks <<  Link.find_by_sql(["SELECT * FROM links WHERE twitter_tweet_id = ?", tweet.twitter_tweet_id])
  #give me a hash where I can get my data without more DB calls
      data[tweet] = uNameAndLinks
    end
    return data
  end
  def get_domain_info_for_table_columns(tweets)
    domain_counts = {}
    tweets.each do |tweet|
      #increment the domain
      domain_counts[tweet.domain] ? domain_counts[tweet.domain] += 1 : domain_counts[tweet.domain] = 1
    end
    return domain_counts
  end
end
