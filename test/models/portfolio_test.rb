require "test_helper"

class PortfolioTest < ActiveSupport::TestCase
  setup do
    @retirement = portfolios(:retirement)
    @trading = portfolios(:trading)
    @empty = portfolios(:empty)
  end

  test "portfolio validity" do
    assert @retirement.valid?
    assert @trading.valid?
    assert @empty.valid?
  end

  test "requires name" do
    portfolio = Portfolio.new(user: users(:one))
    assert_not portfolio.valid?
    assert_includes portfolio.errors[:name], "can't be blank"
  end

  test "requires user" do
    portfolio = Portfolio.new(name: "Test Portfolio")
    assert_not portfolio.valid?
    assert_includes portfolio.errors[:user], "must exist"
  end

  test "total_value calculates correctly" do
    # Google: 15 units * $155.60 = $2,334
    # Apple: 15 units * $180.75 = $2,711.25
    expected_retirement_value = 2334.00 + 2711.25
    assert_in_delta expected_retirement_value, @retirement.total_value, 0.01

    # Gold: 7 units * $2200.99 = $15,406.93
    expected_trading_value = 15406.93
    assert_in_delta expected_trading_value, @trading.total_value, 0.01

    assert_equal 0, @empty.total_value
  end

  test "total_cost calculates correctly" do
    # Google: (10 * $150) + (5 * $145) = $2,225
    # Apple: (20 * $170) = $3,400
    expected_retirement_cost = 2225.00 + 3400.00
    assert_in_delta expected_retirement_cost, @retirement.total_cost, 0.01

    # Gold: 7 * $2000 = $14,000
    expected_trading_cost = 14000.00
    assert_in_delta expected_trading_cost, @trading.total_cost, 0.01

    assert_equal 0, @empty.total_cost
  end

  test "total_gain_loss calculates correctly" do
    # Retirement Portfolio
    # Google unrealized: (15 * $155.60) - (10 * $150 + 5 * $145) = $109
    # Apple unrealized: (15 * $180.75) - (15 * $170) = $161.25
    # Apple realized: (5 * $185) - (5 * $170) = $75
    expected_retirement_gain = 109.00 + 161.25 + 75.00
    assert_in_delta expected_retirement_gain, @retirement.total_gain_loss, 0.01

    # Trading Portfolio
    # Gold unrealized: (7 * $2200.99) - (7 * $2000) = $1,406.93
    expected_trading_gain = 1406.93
    assert_in_delta expected_trading_gain, @trading.total_gain_loss, 0.01

    assert_equal 0, @empty.total_gain_loss
  end

  test "total_return calculates correctly" do
    # Retirement Portfolio
    # Total gain: $345.25
    # Total cost: $5,625
    expected_retirement_return = 345.25 / 5625.00
    assert_in_delta expected_retirement_return, @retirement.total_return, 0.001

    # Trading Portfolio
    # Total gain: $1,406.93
    # Total cost: $14,000
    expected_trading_return = 1406.93 / 14000.00
    assert_in_delta expected_trading_return, @trading.total_return, 0.001

    assert_equal 0, @empty.total_return
  end

  test "allocation_data returns correct structure" do
    data = @retirement.allocation_data
    assert_kind_of Hash, data
    assert_includes data.keys, :labels
    assert_includes data.keys, :values
    assert_equal data[:labels].length, data[:values].length

    # Test empty portfolio
    empty_data = @empty.allocation_data
    assert_equal [], empty_data[:labels]
    assert_equal [], empty_data[:values]
  end

  test "performance_data returns correct structure" do
    data = @retirement.performance_data
    assert_kind_of Hash, data
    assert_includes data.keys, :labels
    assert_includes data.keys, :values
    assert_equal data[:labels].length, data[:values].length
    assert_equal 31, data[:labels].length # Default 30 days + today
  end
end
