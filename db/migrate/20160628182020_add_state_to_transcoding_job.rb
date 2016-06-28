class AddStateToTranscodingJob < ActiveRecord::Migration[5.0]
  def change
    add_column :transcoding_jobs, :state, :integer
  end
end
