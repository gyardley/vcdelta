class Investor < ActiveRecord::Base

  has_many :companies

  accepts_nested_attributes_for :companies, :allow_destroy => true
end
