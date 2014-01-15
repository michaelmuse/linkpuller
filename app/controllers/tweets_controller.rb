class TweetsController < ApplicationController
  def index
    @tweets = Tweet.order(:domain)
    @domain_counts = {}
    @tweets.each do |tweet|
      @domain_counts[tweet.domain] ? @domain_counts[tweet.domain] += 1 : @domain_counts[tweet.domain] = 1
    end
  end
end