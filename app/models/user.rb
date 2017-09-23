class User < ApplicationRecord
  include Clearance::User

  
  has_many :periods, foreign_key: :tutor_id
  belongs_to :group, optional: true
  has_one :profile
  enum user_access: [:admin, :student, :tutor]

  filterrific(
    default_setting: { sorted_by: 'created_at_desc' },
    available_filters: [
      :with_user_access,
      :with_year_level,
    ]
  )

  def name
    first_name + ' ' + last_name
  end

  scope :with_user_access, lambda { |user_access|
    where(user_access: user_access)
  }

  scope :with_year_level, lambda {|year_level|
    where(year_level: year_level)
  }

  self.per_page = 10

  def self.options_for_select_user_access
    user_accesses.keys
  end

  def self.options_for_year_level
    ['Year 10','Year 11','Year 12','Uni']
  end

end
