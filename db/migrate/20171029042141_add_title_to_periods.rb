class AddTitleToPeriods < ActiveRecord::Migration[5.1]
  def change
    add_column :periods, :title, :string
  end
end
