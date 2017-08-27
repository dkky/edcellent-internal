class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :user_access
      t.references :group
      t.string :school
      t.string :year_level
      t.string :wechat_account
      t.string :phone_number
      t.timestamps
    end
  end
end
