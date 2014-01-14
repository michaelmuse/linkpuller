class CreateTwitterNames < ActiveRecord::Migration
  def change
    create_table :twitter_names do |t|
      t.string :username
      t.integer :twitter_name_id

      t.timestamps
    end
  end
end
