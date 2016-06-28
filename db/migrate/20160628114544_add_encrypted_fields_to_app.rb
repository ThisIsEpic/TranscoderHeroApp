class AddEncryptedFieldsToApp < ActiveRecord::Migration[5.0]
  def change
    add_column :apps, :encrypted_s3_access_key_id, :string
    add_column :apps, :encrypted_s3_secret_access_key, :string
    add_column :apps, :encrypted_s3_access_key_id_iv, :string
    add_column :apps, :encrypted_s3_secret_access_key_iv, :string
  end
end
