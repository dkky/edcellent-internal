class AddSessionNumberToPeriod < ActiveRecord::Migration[5.1]
  def change
    add_column :periods, :session_number, :decimal, :precision => 4, :scale => 2
  end
end
