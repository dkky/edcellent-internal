class AddGoogleEventToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :google_event, :boolean
  end
end
