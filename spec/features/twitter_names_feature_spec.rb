require 'spec_helper'

describe "creating a TwitterName" do 
  describe "starting on the new twittername page" do
    before do
      visit new_twitter_name_path
    end
    it "can create a twitter_name; will pull its tweets and store how much it pulled" do
      fill_in 'username', {with: 'hashceratops'}
      select("A few", :from=> "tweet_amount")
      click_button 'submit'
      page.should have_content('hashceratops')
      page.should have_content('74778865')
      page.should have_content('a few')
      Tweet.find_by_twitter_name_id("74778865").should_not be_nil
    end
  end
end
