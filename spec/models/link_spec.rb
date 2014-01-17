require 'spec_helper'

describe Link do
  describe "given two links" do
    before do
      @options = {title: "title", author: "jim", authored_date: "Tue Jan 07 18:06:21 +0000 2014", twitter_tweet_id: "141290871412908714129087"}
      @l1 = Link.new(@options)
      @l2 = Link.new(@options)
      @l1.save
      @l2.save
      #possibly because of uniqueness contraint on the db, cant use Link.create here (breaks)
    end
    #Unique URLs
    describe "and given the urls are unique" do
      before do
        @l1.url = "http://www.theatlantic.com/technology/archive/2014/01/him-love-in-the-time-of-operating-systems/283062/"
        @l1.kind_of_url = "article"
        @l1.save
        @l1.build_attributes
        @l2.url = "http://www.theatlantic.com/business/archive/2013/07/the-economic-cost-of-hangovers/277546/"
        @l2.kind_of_url = "article"
        @l2.save
        @l2.build_attributes

      end
      it "should have the links saved and return the right values" do
        @links = Link.find([@l1.id, @l2.id])
        @links.count.should == 2
        @links.each do |link|
          link.kind_of_url.should == "article"

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
        @l1.save
        @l1.build_attributes
        @l1.save
        @l2.url = "http://4sq.com/1kdpgzr"
        @l2.title = "title2"
        @l2.save
      end
      it "should have only one link saved, with the tag of social and the correct domain" do
        @domain_counts = {}
        @links = Link.all
        @links.count.should == 1
        @links.each do |link|
          link.url.should == "http://4sq.com/1kdpgzr"
          link.domain.should == "4sq.com"
          link.kind_of_url.should == "social"
        end
      end
    end
    #end of duplicate URLs
  end
  describe "given a link we already have attributes for runs through the system" do
    before do
      @l3 = Link.new(author: "test author", authored_date: "Tue Jan 07 18:06:21 +0000 2014", title: "Test title", kind_of_url: "Test kind", url: "http://gawker.com/5624387/new-york-city-restaurants-surprisingly-not-disgusting")
      @l3.save
      @l4 = Link.find(@l3.id)      
    end
    it "Should not overwrite the existing data" do
      @l3.author.should == @l4.author
      @l3.authored_date.should == @l4.authored_date
      @l3.title.should == @l4.title
      @l3.kind_of_url.should == @l4.kind_of_url
    end
  end
end
