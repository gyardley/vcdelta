class AddFieldsToInvestor < ActiveRecord::Migration
  def change
    add_column :investors, :version, :string
    add_column :investors, :investor, :string
    add_column :investors, :url, :string
    add_column :investors, :updated, :datetime
  end
end