class Investment < ApplicationRecord
  belongs_to :portfolio
  has_many :transactions, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  validates :name, presence: true
  validates :current_unit_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  attribute :investment_type, :integer
  attribute :status, :integer
  attribute :exit_target_type, :integer

  enum :investment_type, {
    stock: 0,
    bond: 1,
    mutual_fund: 2,
    etf: 3,
    real_estate: 4,
    cryptocurrency: 5,
    private_equity: 6,
    other: 7
  }

  enum :status, {
    active: 0,
    closed: 1,
    pending: 2
  }

  enum :exit_target_type, {
    specific_date: 0,
    target_unit_value: 1,
    total_investment_value: 2
  }

  def current_value
    return 0 unless total_units && current_unit_price
    total_units * current_unit_price
  end

  def total_units
    transactions.sum do |t|
      t.transaction_type == "buy" ? t.units : -t.units
    end
  end

  def total_cost
    transactions.where(transaction_type: "buy").sum("unit_price * units")
  end

  def total_return
    return 0 if total_cost.zero?
    total_gain_loss / total_cost
    # return 0 if current_unit_price.zero? || average_buy_price.zero?
    # total_units * (current_unit_price - average_buy_price)
  end

  def average_buy_price
    return 0 if total_bought_units.zero?
    total_cost / total_bought_units
  end

  def average_sell_price
    return 0 if total_sold_units.zero?
    total_sold_value / total_sold_units
  end

  def total_bought_units
    transactions.where(transaction_type: "buy").sum(:units)
  end

  def total_sold_units
    transactions.where(transaction_type: "sell").sum(:units)
  end

  def total_sold_value
    transactions.where(transaction_type: "sell").sum("unit_price * units")
  end

  def realized_gain_loss
    total_sold_value - (average_buy_price * total_sold_units)
  end

  def unrealized_gain_loss
    return 0 unless total_units && current_unit_price
    current_value - (average_buy_price * total_units)
  end

  def total_gain_loss
    realized_gain_loss + unrealized_gain_loss
  end

  def holding_period
    first_transaction = transactions.order(transaction_date: :asc).first
    return 0 unless first_transaction
    ((Time.current - first_transaction.transaction_date) / 1.day).round
  end

  def calculate_value_at_date(date)
    relevant_transactions = transactions.where("transaction_date <= ?", date)
    units = relevant_transactions.sum do |t|
      t.transaction_type == "buy" ? t.units : -t.units
    end
    last_price = relevant_transactions.order(transaction_date: :desc).first&.unit_price || 0
    units * last_price
  end

  def performance_data(days = 30)
    start_date = days.days.ago.beginning_of_day
    data_points = transactions
      .where("transaction_date >= ?", start_date)
      .order(transaction_date: :asc)
      .map { |t| [ t.transaction_date.to_date, calculate_value_at_date(t.transaction_date) ] }

    # Add current value if we have one
    if total_units && current_unit_price
      today = Date.current
      data_points << [ today, current_value ] unless data_points.any? { |date, _| date == today }
    end

    # Fill in missing dates with the last known value
    dates = (start_date.to_date..Date.current).to_a
    filled_data = dates.map do |date|
      value = data_points.select { |d, _| d <= date }.max_by { |d, _| d }&.last || 0
      [ date, value ]
    end

    {
      labels: filled_data.map { |date, _| date.strftime("%Y-%m-%d") },
      values: filled_data.map { |_, value| value }
    }
  end
end
