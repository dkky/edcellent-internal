class AddGoogleEventIdToPeriod < ActiveRecord::Migration[5.1]
  def change
    add_column :periods, :google_event_id, :integer
  end
end
