class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true

  validates :content, presence: true
  validates :importance, presence: true,
                        numericality: { only_integer: true,
                                      greater_than_or_equal_to: 1,
                                      less_than_or_equal_to: 5 }

  before_validation :set_default_importance

  private

    def set_default_importance
      self.importance ||= 5
    end
end
