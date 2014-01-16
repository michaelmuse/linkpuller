class AddTweetIdToLinks < ActiveRecord::Migration
  def change
    add_column :links, :tweet_id, :integer
  end
end
