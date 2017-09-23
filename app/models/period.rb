class Period < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: :tutor_id
  belongs_to :group

  enum period_status: [:done, :incomplete]

  filterrific(
    default_setting: { sorted_by: 'created_at_desc' },
    available_filters: [
      :with_different_status,
      :with_different_group,
    ]
  )

  scope :with_different_status, lambda { |period_status|
    where(period_status: period_status)
  }

  scope :with_year_level, lambda {|year_level|
    where(year_level: year_level)
  }  

  scope :with_different_group, lambda { |group|
    where(group_id: group)
  }


  self.per_page = 10


  def self.options_for_different_status
    period_statuses.keys
  end

  def self.options_for_year_level
    ['Year 10','Year 11','Year 12']
  end

  def self.options_for_different_group(user)
    user.periods.map {|period| [period.group.name,period.group.id]}.uniq
  end
end
