class CreateTranscodingJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :transcoding_jobs do |t|
      t.references :app, foreign_key: true
      t.string :input
      t.json :override
      t.json :profiles

      t.timestamps
    end
  end
end
