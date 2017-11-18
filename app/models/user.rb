class User < ApplicationRecord
  include Clearance::User
  # acts_as_taggable # Alias for acts_as_taggable_on :tags
  # acts_as_taggable_on :groupings
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :periods, foreign_key: :tutor_id
  has_many :attending_periods, through: :groups, source: :periods
  # belongs_to :group, optional: true
  has_one :profile
  enum user_access: [:admin, :student, :tutor]

  filterrific(
    default_setting: { sorted_by: 'created_at_desc' },
    available_filters: [
      :with_user_access,
      :with_year_level,
    ]
  )

  scope :with_user_access, lambda { |user_access|
    where(user_access: user_access)
  }

  scope :with_year_level, lambda {|year_level|
    where(year_level: year_level)
  }

  # scope :with_different_grouping, lambda {|grouping|
  #   tagged_with(grouping)
  # }

  self.per_page = 10

  def name
    first_name + ' ' + last_name
  end

  def self.options_for_select_user_access
    user_accesses.keys
  end

  def self.options_for_year_level
    ['Year 10','Year 11','Year 12','Uni']
  end

  # def self.options_for_tagging
  #   ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'groupings').pluck(:name)
  # end
end
