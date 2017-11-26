class Period < ApplicationRecord
  belongs_to :tutor, class_name: "User", foreign_key: :tutor_id
  belongs_to :group
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :groupings
  attr_accessor :date_range

  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :description, :presence => true
  validates :subject, :presence => true
  validates :period_status, :presence => true
  validates :tutor_id, :presence => true
  validates :group_id, :presence => true

  enum period_status: [:done, :incomplete]

  filterrific(
    default_setting: { sorted_by: 'created_at_desc' },
    available_filters: [
      :with_different_status,
      :with_different_group,
      :with_different_grouping,
      :with_start_date,
      :with_end_date
    ]
  )

  searchable do
    text :subject
    text :tutor do
      tutor.first_name
    end
    text :student do
      group.users.map { |user| user.first_name } 
    end
  end

  scope :with_different_status, lambda { |period_status|
    where(period_status: period_status)
  }

  scope :with_year_level, lambda {|year_level|
    where(year_level: year_level)
  }  

  scope :with_different_group, lambda { |group|
    where(group_id: group)
  }

  scope :with_different_grouping, lambda {|grouping|
    tagged_with(grouping)
  }

  scope :with_start_date, lambda { |ref_date|
    where('periods.start_time >= ?', ref_date)
  }  
  
  scope :with_end_date, lambda { |ref_date|
    where('periods.end_time <= ?', ref_date)
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

  def self.options_for_different_group_admin
    Period.all.map {|period| [period.group.name,period.group.id]}.uniq
  end

  def self.options_for_tagging
    ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'groupings').pluck(:name).uniq
  end

  # def self.search(search)
  #   if search
  #     tutor = User.where("first_name LIKE ?", "%#{search}%").first
  #     # where("subject LIKE ?", "%#{search}%") 
  #     where(tutor_id: tutor.id) 
  #   else
  #     all
  #   end
  # end
  # def self.session_number(session_num)
  #   if session_num <= 10
  #     return session_num
  #   elsif session_num > 10 && session_num < 20
  #     session_num = session_num % 10
  #     return session_num
  #   elsif session_num == 20
  #     return 10
  #   elsif session_num > 20 && session_num < 30
  #     session_num = session_num % 20
  #     return session_num
  #   elsif session_num == 30
  #     return 10
  #   elsif session_num > 20 && session_num < 30
  #     session_num = session_num % 20
  #     return session_num
  #   end
  # end
end


