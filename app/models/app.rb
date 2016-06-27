class App < ApplicationRecord
  belongs_to :user
  has_many :profiles, class_name: 'JobProfile'

  validates :name, presence: true
  validates :url, presence: true

  before_create :generate_access_token

  def generate_access_token
    self.access_token ||= loop do
      token = Devise.friendly_token
      break token unless self.class.exists?(access_token: token)
    end
  end
end
