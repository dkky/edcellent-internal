class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.string :text_response
      t.string :comparative_1
      t.string :comparative_2
      t.references :user
      t.timestamps
    end
  end
end
