class AddOutputBucketToApp < ActiveRecord::Migration[5.0]
  def change
    add_column :apps, :s3_output_bucket, :string
  end
end
