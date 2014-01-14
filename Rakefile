#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Linkpuller::Application.load_tasks


namespace :db do 

  desc "Seed my database"
  task :seed do   
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
    # options = {
    #   exclude_replies: true,
    #   include_rts: false,
    #   count: 200,
    # }
    # @tweets = client.user_timeline("michaelmuse", options) 

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

    @tweets = get_all_tweets("msuster")

    @tweets.each do |tweet|
      curr_url = tweet.uris
      unless curr_url == []
        t = Tweet.create
        tn = TwitterName.create
        t.twitter_tweet_id = tweet.attrs[:id]
        t.url = curr_url.first.attrs[:expanded_url]
        t.tweet_date = tweet.attrs[:created_at]
        t.twitter_name_id = tweet.attrs[:user][:id]
        t.text = tweet.attrs[:text]
        # t.domain = curr_url.first.attrs[:expanded_url] #WITH SOME REGEX AFTER
        tn.twitter_name_id = tweet.attrs[:user][:id]
        tn.username = tweet.attrs[:user][:screen_name]
        t.save
        tn.save
      end
    end
  end

  desc "clear the databse"
  task :clear do 
    Tweet.delete_all
    TwitterName.delete_all
  end

end