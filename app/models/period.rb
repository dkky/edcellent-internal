class Period < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: :tutor_id
end
