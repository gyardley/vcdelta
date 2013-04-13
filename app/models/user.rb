class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password, :confirmation => true
  validates :password, :presence => true, :on => :create
  validates :email, :presence => true
  validates :email, :uniqueness => true
end
