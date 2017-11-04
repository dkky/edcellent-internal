class CreateUserGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :user_groups, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true
    end
  end
end
