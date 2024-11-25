class Transaction < ApplicationRecord
  belongs_to :investment
  has_many :notes, as: :notable, dependent: :destroy

  validates :transaction_type, presence: true, inclusion: { in: %w[buy sell] }
  validates :transaction_date, presence: true
  validates :units, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  enum :transaction_type, {
    buy: "buy",
    sell: "sell"
  }

  def total_value
    units * unit_price
  end

  def calculate_portfolio_value_at_date
    investment.portfolio.calculate_value_at_date(transaction_date)
  end

  def calculate_investment_value_at_date
    investment.calculate_value_at_date(transaction_date)
  end

  def self.to_csv
    require "csv"

    CSV.generate(headers: true) do |csv|
      csv << [ "Date", "Investment", "Type", "Units", "Unit Price", "Total Value", "Notes" ]

      all.includes(:investment, :notes).find_each do |transaction|
        csv << [
          transaction.transaction_date.strftime("%Y-%m-%d"),
          transaction.investment.name,
          transaction.transaction_type.titleize,
          transaction.units,
          transaction.unit_price,
          transaction.total_value,
          transaction.notes.map(&:content).join(" | ")
        ]
      end
    end
  end

  def self.to_json_export
    includes(:investment, :notes).map do |transaction|
      {
        date: transaction.transaction_date.strftime("%Y-%m-%d"),
        investment: transaction.investment.name,
        type: transaction.transaction_type,
        units: transaction.units,
        unit_price: transaction.unit_price,
        total_value: transaction.total_value,
        notes: transaction.notes.map { |note| { content: note.content, importance: note.importance } }
      }
    end.to_json
  end

  def self.date_range_options
    [
      [ "Last 7 days", 7.days.ago.beginning_of_day ],
      [ "Last 30 days", 30.days.ago.beginning_of_day ],
      [ "Last 90 days", 90.days.ago.beginning_of_day ],
      [ "Last 180 days", 180.days.ago.beginning_of_day ],
      [ "Last 365 days", 365.days.ago.beginning_of_day ],
      [ "All time", 100.years.ago ]
    ]
  end
end
