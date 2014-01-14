require 'spec_helper'

describe TwitterName do
  describe "given two TwitterNames" do
    before do
      @tn1 = TwitterName.create(username: "Bill")
      @tn2 = TwitterName.create(username: "Sarah")
    end
    #Unique IDs
    describe "and given the twitter name ids are unique" do
      before do
        @tn1.twitter_name_id = 1
        @tn1.save
        @tn2.twitter_name_id = 2
        @tn2.save
      end
      it "should have the tnames saved and return the right values" do
        @tnames = TwitterName.all
        @tnames.count.should == 2
        @tnames[0][:username].should == "Bill"
        @tnames[1][:username].should == "Sarah"
      end
    end
    ##end of unique
    #Non-Unique IDs
    describe "and given the tweet ids arent unique" do
      before do
        @tn1.twitter_name_id = 1
        @tn1.save
        @tn2.twitter_name_id = 1
        @tn2.save
      end
      it "should have only the one user" do
        @tnames = TwitterName.all
        @tnames.count.should == 1
      end
    end
    ##end of non-unique
  end
end
