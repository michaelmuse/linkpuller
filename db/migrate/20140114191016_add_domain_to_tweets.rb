class AddDomainToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :domain, :string
  end
end
