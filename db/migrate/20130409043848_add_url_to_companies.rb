class AddUrlToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :url, :string
  end
end
