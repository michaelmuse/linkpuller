require 'spec_helper'

describe Tweet do
  describe "given two tweets" do
    before do
      @options = {url: "http://www.theatlantic.com/technology/archive/2014/01/him-love-in-the-time-of-operating-systems/283062/", tweet_date: "Tue Jan 07 18:06:21 +0000 2014", twitter_name_id: 14129087}
      @t1 = Tweet.new(@options)
      @t2 = Tweet.new(@options)
      #possibly because of uniqueness contraint on the db, cant use Tweet.create here (breaks)
    end
    #Unique IDs
    describe "and given the tweet ids are unique" do
      before do
        @t1.twitter_tweet_id = 1
        @t1.build_domain
        @t1.save
        @t2.twitter_tweet_id = 2
        @t2.build_domain
        @t2.save
      end
      it "should have the tweets saved and return the right values" do
        @domain_counts = {}
        @tweets = Tweet.all
        @tweets.count.should == 2
        @tweets.each do |tweet|
          tweet.url.should == @options[:url]
          tweet.tweet_date.should == @options[:tweet_date]
          tweet.twitter_name_id.should == @options[:twitter_name_id]
          tweet.domain.should == "www.theatlantic.com"
          @domain_counts[tweet.url] ? @domain_counts[tweet.url] += 1 : @domain_counts[tweet.url] = 1
          @domain_counts[tweet.url].should be > 0
        end
      end
    end
    ##end of unique
    #Non-Unique IDs
    describe "and given the tweet ids arent unique" do
      before do
        @t1.twitter_tweet_id = 1
        @t1.save
        @t2.twitter_tweet_id = 1
        @t2.save
      end
      it "should have only saved one tweet" do
        @tweets = Tweet.all
        @tweets.count.should == 1
      end
    end
    ##end of non-unique
  end
end
