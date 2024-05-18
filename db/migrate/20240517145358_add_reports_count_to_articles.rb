class AddReportsCountToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :reports_count, :integer, default: 0
  end
end
