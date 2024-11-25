class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :note_drafts, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
