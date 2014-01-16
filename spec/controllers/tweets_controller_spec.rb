require 'spec_helper'

describe TweetsController do
  describe "given a tweet, when visiting index" do
    before do
      @tweet = Tweet.create
      get :index
    end
    it "retrieves all tweets" do
      assigns(:data).keys.should == Tweet.all
    end
  end
end