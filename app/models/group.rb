class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :periods

  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :tutors

  enum group_status: [:fixed, :random, :inactive]

  filterrific(
    default_setting: { sorted_by: 'created_at_desc' },
    available_filters: [
      :with_different_tutor,
      :with_different_grouping,
      :with_different_name,
      :with_different_group_status
    ]
  )

  self.per_page = 10


  # scope :with_different_grouping, lambda {|grouping|
  #   tagged_with(grouping)
  # }

  scope :with_different_name, lambda { |group_name|
    where(name: group_name)
  }  

  scope :with_different_group_status, lambda { |group_stat|
    where(group_status: group_stat)
  }

  # scope :with_different_grouping, -> (group_type) { joins(:users).group("groups.id HAVING count(users.id) = " + group_type.to_s) }
  # scope :with_different_grouping, ->(n) { where("(SELECT COUNT(*) FROM groups WHERE user_id = users.id) = ?", n) }


  scope :with_different_tutor, lambda {|tutor|
    unless tagged_with(tutor)
      return []
    else 
      tagged_with(tutor)
    end
  }

  def self.options_for_grouping
    ["1","2","3","4","5","6","7"]
    # ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'groupings').pluck(:name).uniq
  end

  def self.options_for_different_status
    group_statuses.keys
  end


  def self.options_for_name
    Group.all.map {|group| group.name}
  end

  def self.options_for_tutor
    unless ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'tutors').pluck(:name).uniq
      return User.all.map {|u| u.eng_version_name}
    else 
      return ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'tutors').pluck(:name).uniq    
    end
  end
end
