class CreatePeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :periods do |t|
      t.string :description
      t.string :note
      t.integer :tutor_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :period_status

      t.timestamps
    end
  end
end
