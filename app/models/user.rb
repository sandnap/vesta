class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :note_drafts, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validate :password_complexity, if: -> { password.present? }

  private

    def password_complexity
      # Check minimum length
      if password.length < 6
        errors.add :password, "must be at least 6 characters"
        return
      end

      # Check for required character types
      unless password.match?(/[A-Z]/) # Has uppercase
        errors.add :password, "must include at least one uppercase letter"
      end

      unless password.match?(/[a-z]/) # Has lowercase
        errors.add :password, "must include at least one lowercase letter"
      end

      unless password.match?(/[0-9\W]/) # Has number or special char
        errors.add :password, "must include at least one number or special character"
      end
    end
end
