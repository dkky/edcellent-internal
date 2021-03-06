class Period < ApplicationRecord
  include PgSearch

  # after_save :check_session_number

  belongs_to :tutor, class_name: "User", foreign_key: :tutor_id
  belongs_to :group
  has_many :user_groups, through: :group
  has_many :students, through: :user_groups, source: :user
  # has_many :students, through: :user_groups, source: :periods, class_name: "User", foreign_key: "user_id"
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :groupings
  attr_accessor :date_range

  validates :start_time, :presence => true
  validates :end_time, :presence => true
  # validates :description, :presence => true
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
      :with_different_tutor,
      :with_different_grouping,
      :with_start_date,
      :with_end_date,
      :sorted_by
    ]
  )

  pg_search_scope :calendar_search, :associated_against => {
    :students => [:english_name, :first_name, :last_name],
    :tutor => [:english_name, :first_name, :last_name]
  }

  # multisearchable :against => [users_in_group]
  # pg_search_scope :tutor_search, :associated_against => {
  #   # :group => [users_in_group],
  #   :tutor => [:first_name, :last_name]
  # }

  # searchable do
  #   text :subject
  #   text :tutor do
  #     tutor.first_name
  #   end
  #   text :student do
  #     group.users.map { |user| user.first_name } 
  #   end
  # end
  # for sunspot...

  scope :with_different_status, lambda { |period_status|
    where(period_status: period_status)
  }

  scope :with_year_level, lambda {|year_level|
    where(year_level: year_level)
  }  

  scope :with_different_group, lambda { |group|
    where(group_id: group)
  }  

  scope :with_different_tutor, lambda { |tutor|
    where(tutor_id: tutor)
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

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      order("end_time #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }


  self.per_page = 10


  def users_in_group
    # group.users.map {|u| u.name}
    group.users.first.name 
  end

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

  def self.options_for_different_tutor_admin
    Period.all.map {|period| [period.tutor.eng_version_name,period.tutor_id]}.uniq
  end  

  def self.options_for_different_group_based_on_tutors(tutor)
    tutor.periods.map {|period| [period.group.name,period.group.id]}.uniq
  end

  def self.options_for_tagging
    ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'groupings').pluck(:name).uniq
  end

  def self.options_for_sorted_by
    [
      ['Session date (newest first)', 'created_at_desc'],
      ['Session date (oldest first)', 'created_at_asc'],
    ]
  end

  def check_session_number
    # byebug
    if self.session_number.to_s == "9.0" || self.session_number.to_s == "10.0"
      session = self.title
      date =  self.start_time.strftime("%d/%-m %a")
      time = self.start_time.strftime("%-I:%M%p") + " - " + self.end_time.strftime("%-I:%M %p")
      message = "\n@channel\n```\n\n\ #{session} \n #{date} \n #{time} \n is it time to collect fees? \n if yes, please add the students to the respective sales sheet```"
      # SlackJob.perform_later(message: message, random: '')

    end
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


