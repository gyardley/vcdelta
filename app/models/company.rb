class Company < ActiveRecord::Base

  belongs_to :investor
  has_many :rounds
  has_many :events

  accepts_nested_attributes_for :rounds, :events, :allow_destroy => true

end
