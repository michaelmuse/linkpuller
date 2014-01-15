class AddTweetsCollectedToTwitterName < ActiveRecord::Migration
  def change
    add_column :twitter_names, :tweets_collected, :string
  end
end
