class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :investments, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :transactions, through: :investments

  validates :name, presence: true

  def allocation_data
    # Only include investments with positive value
    valid_investments = investments.select { |i| i.current_value.to_f > 0 }

    # Return empty data if no valid investments
    return { labels: [], values: [] } if valid_investments.empty?

    # Calculate total portfolio value for percentage calculation
    total_value = valid_investments.sum(&:current_value)

    # Map investments to data points
    investment_data = valid_investments.map do |investment|
      percentage = (investment.current_value / total_value) * 100
      {
        label: "#{investment.name} (#{number_to_percentage(percentage, precision: 1)})",
        value: investment.current_value.to_f
      }
    end

    # Sort by value descending
    investment_data.sort_by! { |d| -d[:value] }

    {
      labels: investment_data.map { |d| d[:label] },
      values: investment_data.map { |d| d[:value] }
    }
  end

  def performance_data(days = 30)
    start_date = days.days.ago.beginning_of_day
    dates = (start_date.to_date..Date.current).to_a

    # Calculate portfolio value for each date
    data_points = dates.map do |date|
      value = investments.sum do |investment|
        investment.calculate_value_at_date(date)
      end
      [ date, value ]
    end

    {
      labels: data_points.map { |date, _| date.strftime("%Y-%m-%d") },
      values: data_points.map { |_, value| value }
    }
  end

  def total_value
    investments.sum(&:current_value)
  end

  def total_cost
    investments.sum(&:total_cost)
  end

  def total_return
    return 0 if total_cost.zero?
    total_gain_loss / total_cost
  end

  def realized_gain_loss
    investments.sum(&:realized_gain_loss)
  end

  def unrealized_gain_loss
    investments.sum(&:unrealized_gain_loss)
  end

  def total_gain_loss
    realized_gain_loss + unrealized_gain_loss
  end

  private

    def number_to_percentage(number, options = {})
      precision = options.fetch(:precision, 1)
      "#{number.round(precision)}%"
    end
end
