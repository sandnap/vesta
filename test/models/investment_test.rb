require "test_helper"

class InvestmentTest < ActiveSupport::TestCase
  setup do
    @google = investments(:google_stock)
    @apple = investments(:apple_stock)
    @gold = investments(:gold_etf)
    @closed = investments(:closed_investment)
  end

  test "investment validity" do
    assert @google.valid?
    assert @apple.valid?
    assert @gold.valid?
    assert @closed.valid?
  end

  test "requires name" do
    investment = Investment.new(portfolio: portfolios(:retirement))
    assert_not investment.valid?
    assert_includes investment.errors[:name], "can't be blank"
  end

  test "requires portfolio" do
    investment = Investment.new(name: "Test Investment")
    assert_not investment.valid?
    assert_includes investment.errors[:portfolio], "must exist"
  end

  test "current_value calculates correctly" do
    # Google: 15 units * $155.60
    assert_in_delta 2334.00, @google.current_value, 0.01

    # Apple: 15 units * $180.75
    assert_in_delta 2711.25, @apple.current_value, 0.01

    # Gold: 7 units * $2200.99
    assert_in_delta 15406.93, @gold.current_value, 0.01

    # Closed investment should have zero value
    assert_equal 0, @closed.current_value
  end

  test "total_units calculates correctly" do
    # Google: 10 + 5 = 15 units
    assert_equal 15.0, @google.total_units

    # Apple: 20 - 5 = 15 units (after partial sell)
    assert_equal 15.0, @apple.total_units

    # Gold: 7 units
    assert_equal 7.0, @gold.total_units

    # Closed: 0 units
    assert_equal 0.0, @closed.total_units
  end

  test "total_cost calculates correctly" do
    # Google: (10 * $150) + (5 * $145)
    assert_in_delta 2225.00, @google.total_cost, 0.01

    # Apple: 20 * $170
    assert_in_delta 3400.00, @apple.total_cost, 0.01

    # Gold: 7 * $2000
    assert_in_delta 14000.00, @gold.total_cost, 0.01
  end

  test "total_return calculates correctly" do
    # Google unrealized: $109 gain / $2,225 cost
    assert_in_delta 0.049, @google.total_return, 0.001

    # Apple: $236.25 total gain / $3,400 cost
    assert_in_delta 0.069, @apple.total_return, 0.001

    # Gold: $1,406.93 gain / $14,000 cost
    assert_in_delta 0.101, @gold.total_return, 0.001
  end

  test "average_buy_price calculates correctly" do
    # Google: (10 * $150 + 5 * $145) / 15
    assert_in_delta 148.33, @google.average_buy_price, 0.01

    # Apple: (20 * $170) / 20
    assert_in_delta 170.00, @apple.average_buy_price, 0.01

    # Gold: (7 * $2000) / 7
    assert_in_delta 2000.00, @gold.average_buy_price, 0.01
  end

  test "average_sell_price calculates correctly" do
    # Apple: (5 * $185) / 5
    assert_in_delta 185.00, @apple.average_sell_price, 0.01

    # Google and Gold have no sells
    assert_equal 0, @google.average_sell_price
    assert_equal 0, @gold.average_sell_price
  end

  test "realized_gain_loss calculates correctly" do
    # Apple: (5 * $185) - (5 * $170)
    assert_in_delta 75.00, @apple.realized_gain_loss, 0.01

    # Google and Gold have no realized gains/losses
    assert_equal 0, @google.realized_gain_loss
    assert_equal 0, @gold.realized_gain_loss
  end

  test "unrealized_gain_loss calculates correctly" do
    # Google: (15 * $155.60) - (15 * $148.33)
    assert_in_delta 109.00, @google.unrealized_gain_loss, 0.01

    # Apple: (15 * $180.75) - (15 * $170)
    assert_in_delta 161.25, @apple.unrealized_gain_loss, 0.01

    # Gold: (7 * $2200.99) - (7 * $2000)
    assert_in_delta 1406.93, @gold.unrealized_gain_loss, 0.01
  end

  test "holding_period calculates correctly" do
    # All investments should have a holding period > 0
    assert @google.holding_period > 0
    assert @apple.holding_period > 0
    assert @gold.holding_period > 0

    # Apple should have the longest holding period (60 days)
    assert @apple.holding_period > @google.holding_period
    assert @apple.holding_period > @gold.holding_period
  end

  test "calculate_value_at_date returns correct values" do
    date = 20.days.ago.to_date

    # Google should use price from first transaction for dates before second buy
    expected_google_value = 10 * 150.00 # Only first purchase counted
    assert_in_delta expected_google_value, @google.calculate_value_at_date(date), 0.01

    # Apple should reflect all transactions before the date
    expected_apple_value = 20 * 170.00 # Initial purchase only
    assert_in_delta expected_apple_value, @apple.calculate_value_at_date(date), 0.01
  end

  test "performance_data returns correct structure" do
    data = @google.performance_data
    assert_kind_of Hash, data
    assert_includes data.keys, :labels
    assert_includes data.keys, :values
    assert_equal data[:labels].length, data[:values].length
    assert_equal 31, data[:labels].length # Default 30 days + today
  end

  test "enums are defined correctly" do
    assert_equal "stock", @google.investment_type
    assert_equal "etf", @gold.investment_type
    assert_equal "mutual_fund", @closed.investment_type
    assert_equal "active", @google.status
    assert_equal "closed", @closed.status
  end
end
