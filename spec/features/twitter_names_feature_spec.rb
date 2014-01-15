require 'spec_helper'

describe "creating a TwitterName" do 
  describe "starting on the new twittername page" do
    before do
      visit new_twitter_name_path
    end
    it "can create a twitter_name; will pull its tweets and store how much it pulled" do
      fill_in 'username', {with: 'michaelmuse'}
      select("Some", :from=> "tweet_amount")
      click_button 'submit'
      page.should have_content('michaelmuse')
      page.should have_content('14129087')
      page.should have_content('some')
      Tweet.find_by_twitter_name_id('14129087').should_not be_nil
    end
  end
end


describe "viewing a twitter_name" do
  before do
    @michaelmuse = TwitterName.create username: 'michaelmuse', twitter_name_id: '14129087', tweets_collected: 'some'
    visit twitter_name_path(@michaelmuse)
  end
  it "should have a content rich show page" do 
    page.should have_content(@michaelmuse.username)
    page.should have_content(@michaelmuse.tweets_collected)    
  end


end 

