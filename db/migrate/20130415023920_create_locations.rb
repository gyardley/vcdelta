class CreateLocations < ActiveRecord::Migration
  def change

    create_table :locations do |t|
      t.string :name
      t.string :url
    end

  end
end
