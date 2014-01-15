class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :domain
      t.string :url, unique: true
      t.string :twitter_tweet_id
      t.string :author
      t.string :title
      t.datetime :authored_date
      t.string :url_type

      t.timestamps
    end
  end
end
