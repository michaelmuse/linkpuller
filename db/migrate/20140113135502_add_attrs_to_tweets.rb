class AddAttrsToTweets < ActiveRecord::Migration
  def change
    change_table :tweets do |t|
      t.change :tweet_id, :integer
      t.change :url, :string
      t.change :date, 
    end
  end
end
