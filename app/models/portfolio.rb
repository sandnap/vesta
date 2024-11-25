class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :investments, dependent: :destroy
  has_many :transactions, through: :investments
  has_many :notes, as: :notable, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id, message: "has already been used for another portfolio" }

  def total_value
    investments.sum(&:current_value)
  end

  def total_cost
    transactions.where(transaction_type: "buy").sum("unit_price * units")
  end

  def total_return
    return 0 if total_cost.zero?
    (total_value - total_cost) / total_cost
  end

  def calculate_value_at_date(date)
    transactions.where("transaction_date <= ?", date).sum do |t|
      if t.transaction_type == "buy"
        t.unit_price * t.units
      else
        -(t.unit_price * t.units)
      end
    end
  end
end
