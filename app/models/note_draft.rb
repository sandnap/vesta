class NoteDraft < ApplicationRecord
  belongs_to :notable, polymorphic: true
  belongs_to :user

  validates :content, presence: true
  validates :importance, presence: true,
                        numericality: { only_integer: true,
                                      greater_than_or_equal_to: 1,
                                      less_than_or_equal_to: 5 }
  validates :last_autosaved_at, presence: true
  validates :notable_id, uniqueness: { scope: [ :notable_type, :user_id ] }

  before_validation :set_default_importance
  before_validation :set_last_autosaved_at

  def to_note
    Note.new(
      content: content,
      importance: importance,
      notable: notable
    )
  end

  private

    def set_default_importance
      self.importance ||= 5
    end

    def set_last_autosaved_at
      self.last_autosaved_at = Time.current
    end
end
