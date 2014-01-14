require 'spec_helper'

describe Tweet do
  describe "given two tweets" do
    before do
      @options = {url: "http://alleywat.ch/1", tweet_date: "Tue Jan 07 18:06:21 +0000 2014", twitter_name_id: 14129087, domain: "michaelmuse.com"}
      @t1 = Tweet.create(@options)
      @t2 = Tweet.create(@options)
    end
    #Unique IDs
    describe "and given the tweet ids are unique" do
      before do
        @t1.twitter_tweet_id = 1
        @t1.save
        @t2.twitter_tweet_id = 2
        @t2.save
      end
      it "should have the tweets saved and return the right values" do
        @tweets = Tweet.all
        @tweets.count.should == 2
        @tweets.each do |tweet|
          tweet.url.should == @options[:url]
          tweet.tweet_date.should == @options[:tweet_date]
          tweet.twitter_name_id.should == @options[:twitter_name_id]
          tweet.domain.should == @options[:domain]
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
