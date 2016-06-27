class CreateApps < ActiveRecord::Migration[5.0]
  def change
    create_table :apps do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :access_token

      t.timestamps
    end
  end
end
