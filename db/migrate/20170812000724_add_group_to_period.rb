class AddGroupToPeriod < ActiveRecord::Migration[5.1]
  def change
    add_reference :periods, :group, foreign_key: true
  end
end
