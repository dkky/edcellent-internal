class ChangeDataTypeForGoogleEventInPeriod < ActiveRecord::Migration[5.1]
  def up
    change_table :periods do |t|
      t.change :google_event_id, :string
    end
  end
  
  def down
    change_table :periods do |t|
      t.change :google_event_id, :integer
    end
  end
end
