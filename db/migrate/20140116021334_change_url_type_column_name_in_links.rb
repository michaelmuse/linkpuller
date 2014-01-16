class ChangeUrlTypeColumnNameInLinks < ActiveRecord::Migration
  def up
    rename_column :links, :url_type, :kind_of_url
  end

  def down
    rename_column :links, :kind_of_url, :url_type
  end
end
