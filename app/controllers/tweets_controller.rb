class TweetsController < ApplicationController
  def index
    @tweets = Tweet.order(:domain)
  end

end