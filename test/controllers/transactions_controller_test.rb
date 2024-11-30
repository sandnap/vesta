require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @portfolio = portfolios(:retirement)
    @investment = investments(:google_stock)
    @transaction = transactions(:google_buy)

    # Log in
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"
    }
    assert_response :redirect
    follow_redirect!
  end

  test "should get index as CSV" do
    get portfolio_investment_transactions_url(@portfolio, @investment, format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match /Date,Investment,Type,Units,Unit Price,Total Value,Notes/, response.body
  end

  test "should get index as JSON" do
    get portfolio_investment_transactions_url(@portfolio, @investment, format: :json)
    assert_response :success
    assert_equal "application/json", response.media_type
    assert_match /"date":/, response.body
  end

  test "should get new from investment" do
    get new_portfolio_investment_transaction_url(@portfolio, @investment)
    assert_response :success
  end

  test "should get new from portfolio" do
    get new_portfolio_transaction_url(@portfolio)
    assert_response :success
  end

  test "should create transaction from investment" do
    assert_difference("Transaction.count") do
      post portfolio_investment_transactions_url(@portfolio, @investment), params: {
        transaction: {
          transaction_date: Time.current,
          transaction_type: "buy",
          units: 10,
          unit_price: 150.00
        }
      }
    end

    assert_redirected_to portfolio_investment_url(@portfolio, @investment)
    assert_equal "Transaction was successfully created.", flash[:notice]
  end

  test "should create transaction from portfolio" do
    assert_difference("Transaction.count") do
      post portfolio_transactions_url(@portfolio), params: {
        transaction: {
          investment_id: @investment.id,
          transaction_date: Time.current,
          transaction_type: "buy",
          units: 10,
          unit_price: 150.00
        }
      }
    end

    assert_redirected_to portfolio_investment_url(@portfolio, @investment)
    assert_equal "Transaction was successfully created.", flash[:notice]
  end

  test "should create transaction with turbo stream" do
    assert_difference("Transaction.count") do
      post portfolio_investment_transactions_url(@portfolio, @investment), params: {
        transaction: {
          transaction_date: Time.current,
          transaction_type: "buy",
          units: 10,
          unit_price: 150.00
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not create transaction with invalid params" do
    assert_no_difference("Transaction.count") do
      post portfolio_investment_transactions_url(@portfolio, @investment), params: {
        transaction: {
          transaction_date: nil,  # Date is required
          transaction_type: "buy",
          units: 10,
          unit_price: 150.00
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_portfolio_investment_transaction_url(@portfolio, @investment, @transaction)
    assert_response :success
  end

  test "should update transaction" do
    patch portfolio_investment_transaction_url(@portfolio, @investment, @transaction), params: {
      transaction: {
        units: 15,
        unit_price: 160.00
      }
    }

    assert_redirected_to portfolio_investment_url(@portfolio, @investment)
    assert_equal "Transaction was successfully updated.", flash[:notice]
    @transaction.reload
    assert_equal 15, @transaction.units
    assert_equal 160.00, @transaction.unit_price
  end

  test "should update transaction with turbo stream" do
    patch portfolio_investment_transaction_url(@portfolio, @investment, @transaction), params: {
      transaction: {
        units: 15,
        unit_price: 160.00
      }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    @transaction.reload
    assert_equal 15, @transaction.units
    assert_equal 160.00, @transaction.unit_price
  end

  test "should not update transaction with invalid params" do
    patch portfolio_investment_transaction_url(@portfolio, @investment, @transaction), params: {
      transaction: {
        transaction_date: nil  # Date is required
      }
    }

    assert_response :unprocessable_entity
    @transaction.reload
    assert_not_nil @transaction.transaction_date
  end

  test "should destroy transaction" do
    assert_difference("Transaction.count", -1) do
      delete portfolio_investment_transaction_url(@portfolio, @investment, @transaction), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should get export page" do
    get export_portfolio_investment_transactions_url(@portfolio, @investment)
    assert_response :success
  end

  test "should export transactions as CSV with date range" do
    get export_portfolio_investment_transactions_url(@portfolio, @investment,
      params: { start_date: 30.days.ago.to_date.to_s },
      format: :csv
    )
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match /Date,Investment,Type,Units,Unit Price,Total Value,Notes/, response.body
  end

  test "should export transactions as JSON with date range" do
    get export_portfolio_investment_transactions_url(@portfolio, @investment,
      params: { start_date: 30.days.ago.to_date.to_s },
      format: :json
    )
    assert_response :success
    assert_equal "application/json", response.media_type
    assert_match /"date":/, response.body
  end

  test "should not allow access to other user's portfolio transactions" do
    other_portfolio = portfolios(:trading)  # Belongs to users(:two)
    other_investment = investments(:gold_etf)
    other_transaction = transactions(:gold_buy)

    get portfolio_investment_transactions_url(other_portfolio, other_investment)
    assert_response :not_found

    get new_portfolio_investment_transaction_url(other_portfolio, other_investment)
    assert_response :not_found

    post portfolio_investment_transactions_url(other_portfolio, other_investment), params: {
      transaction: { units: 10, unit_price: 100 }
    }
    assert_response :not_found

    get edit_portfolio_investment_transaction_url(other_portfolio, other_investment, other_transaction)
    assert_response :not_found

    patch portfolio_investment_transaction_url(other_portfolio, other_investment, other_transaction), params: {
      transaction: { units: 15 }
    }
    assert_response :not_found

    delete portfolio_investment_transaction_url(other_portfolio, other_investment, other_transaction)
    assert_response :not_found
  end

  test "should require authentication" do
    delete session_url  # Log out

    get portfolio_investment_transactions_url(@portfolio, @investment)
    assert_redirected_to new_session_url

    get new_portfolio_investment_transaction_url(@portfolio, @investment)
    assert_redirected_to new_session_url

    post portfolio_investment_transactions_url(@portfolio, @investment), params: {
      transaction: { units: 10, unit_price: 100 }
    }
    assert_redirected_to new_session_url

    get edit_portfolio_investment_transaction_url(@portfolio, @investment, @transaction)
    assert_redirected_to new_session_url

    patch portfolio_investment_transaction_url(@portfolio, @investment, @transaction), params: {
      transaction: { units: 15 }
    }
    assert_redirected_to new_session_url

    delete portfolio_investment_transaction_url(@portfolio, @investment, @transaction)
    assert_redirected_to new_session_url
  end
end
