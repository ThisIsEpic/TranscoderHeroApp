class AddOutputDataToTranscodingJob < ActiveRecord::Migration[5.0]
  def change
    add_column :transcoding_jobs, :output_data, :json
  end
end
