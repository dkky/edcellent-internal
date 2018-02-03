class AddEnglishNameToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :english_name, :string
  end
end
