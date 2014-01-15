class AddAttrsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :twitter_tweet_id, :string
    add_column :tweets, :url, :string
    add_column :tweets, :tweet_date, :datetime
    add_column :tweets, :twitter_name_id, :string
    add_index :tweets, :twitter_tweet_id, unique: true
  end
end
