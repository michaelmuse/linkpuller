require 'spec_helper'

describe TweetsController do
  describe "when visiting index" do
    before do
      get :index
    end
    it "retrieves all tweets" do
      assigns(:tweets).should == Tweet.all
    end
  end
end














# describe MusiciansController do
#   end
#   describe "Given the potential for Axl Rose" do
#     before do 
#       @potential_axl = {name: "Axl Rose", age: 6}
#     end 
#     describe "when posting to index" do
#       before do
#         post :create, @potential_axl
#       end
#       it "should create Mr Rose" do
#         Musician.where({age: 6}).first.name.should == "Axl Rose"
#       end
#     end
#   end
# end
