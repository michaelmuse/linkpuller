class AddTwitterUsernamesIndex < ActiveRecord::Migration
  def change
    add_index :twitter_names, :twitter_name_id, :unique => true
  end
end
