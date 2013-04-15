class Location < ActiveRecord::Base

  validates :name, :url, :presence => true

end