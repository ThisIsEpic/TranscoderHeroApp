class App < ApplicationRecord
  belongs_to :user
  has_many :profiles, class_name: 'JobProfile'

  attr_encrypted :s3_access_key_id, key: -> (_) { Rails.application.secrets.encryption_key }
  attr_encrypted :s3_secret_access_key, key: -> (_) { Rails.application.secrets.encryption_key }

  validates :name, presence: true
  validates :url, presence: true

  before_create :generate_access_token, :generate_s3_output_bucket
  after_create :s3_tasks

  def generate_s3_output_bucket
    self.s3_output_bucket = SecureRandom.uuid
  end

  def s3_tasks
    app_manager = AppManager.new(self)
    app_manager.create_bucket!
    app_manager.put_cors_policy!
  end

  def generate_access_token
    self.access_token ||= loop do
      token = Devise.friendly_token
      break token unless self.class.exists?(access_token: token)
    end
  end
end
