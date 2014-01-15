require 'spec_helper'

describe Link do
  describe "given two links" do
    before do
      @options = {url_type: "article", title: "title", author: "jim", authored_date: "Tue Jan 07 18:06:21 +0000 2014", twitter_tweet_id: "141290871412908714129087"}
      @l1 = Link.new(@options)
      @l2 = Link.new(@options)
      #possibly because of uniqueness contraint on the db, cant use Link.create here (breaks)
    end
    #Unique URLs
    describe "and given the urls are unique" do
      before do
        @l1.url = "http://www.theatlantic.com/technology/archive/2014/01/him-love-in-the-time-of-operating-systems/283062/"
        @l1.build_attributes
        @l1.save
        @l2.url = "http://www.theatlantic.com/business/archive/2013/07/the-economic-cost-of-hangovers/277546/"
        @l2.build_attributes
        @l2.save
      end
      it "should have the links saved and return the right values" do
        @links = Link.all
        @links.count.should == 2
        @links.each do |link|
          link.url_type.should == @options[:url_type]
          link.title.should == @options[:title]
          link.author.should == @options[:author]
          link.authored_date.should == @options[:authored_date]
          link.twitter_tweet_id.should == @options[:twitter_tweet_id]
          link.domain.should == "www.theatlantic.com"
        end
      end
    end
    #end of Unique urls
    describe "and given the urls are the same and social" do
      before do
        @l1.url = "http://4sq.com/1kdpgzr"
        @l1.build_attributes
        @l1.save
        @l2.url = "http://4sq.com/1kdpgzr"
        @l2.build_attributes
        @l2.save
      end
      it "should have only one link saved, with the tag of social and the correct domain" do
        @domain_counts = {}
        @links = Link.all
        @links.count.should == 1
        @links.each do |link|
          link.url.should == "http://4sq.com/1kdpgzr"
          link.domain.should == "4sq.com"
        end
      end
    end
    #end of duplicate URLs
  end
end
