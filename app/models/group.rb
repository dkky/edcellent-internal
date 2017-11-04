class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :periods

  enum group_status: [:fixed, :random]

end
