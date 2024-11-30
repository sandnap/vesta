require "test_helper"

class InvestmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @portfolio = portfolios(:retirement)
    @investment = investments(:google_stock)

    # Log in
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"
    }
    assert_response :redirect
    follow_redirect!
  end

  test "should get new" do
    get new_portfolio_investment_url(@portfolio)
    assert_response :success
  end

  test "should create investment" do
    assert_difference("Investment.count") do
      post portfolio_investments_url(@portfolio), params: {
        investment: {
          name: "New Test Investment",
          symbol: "TEST",
          investment_type: "stock",
          status: "active",
          current_unit_price: 100.00
        }
      }
    end

    assert_redirected_to portfolio_url(@portfolio)
    assert_equal "Investment was successfully created.", flash[:notice]
  end

  test "should create investment with turbo stream" do
    assert_difference("Investment.count") do
      post portfolio_investments_url(@portfolio), params: {
        investment: {
          name: "New Test Investment",
          symbol: "TEST",
          investment_type: "stock",
          status: "active",
          current_unit_price: 100.00
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not create investment with invalid params" do
    assert_no_difference("Investment.count") do
      post portfolio_investments_url(@portfolio), params: {
        investment: {
          name: "",  # Name is required
          symbol: "TEST",
          investment_type: "stock"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show investment" do
    get portfolio_investment_url(@portfolio, @investment)
    assert_response :success
  end

  test "should get edit" do
    get edit_portfolio_investment_url(@portfolio, @investment)
    assert_response :success
  end

  test "should update investment" do
    patch portfolio_investment_url(@portfolio, @investment), params: {
      investment: {
        name: "Updated Investment Name",
        current_unit_price: 200.00
      }
    }

    assert_redirected_to portfolio_url(@portfolio)
    assert_equal "Investment was successfully updated.", flash[:notice]
    @investment.reload
    assert_equal "Updated Investment Name", @investment.name
    assert_equal 200.00, @investment.current_unit_price
  end

  test "should update investment with turbo stream" do
    patch portfolio_investment_url(@portfolio, @investment), params: {
      investment: {
        name: "Updated Investment Name",
        current_unit_price: 200.00
      }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    @investment.reload
    assert_equal "Updated Investment Name", @investment.name
    assert_equal 200.00, @investment.current_unit_price
  end

  test "should not update investment with invalid params" do
    patch portfolio_investment_url(@portfolio, @investment), params: {
      investment: {
        name: "",  # Name is required
        current_unit_price: 200.00
      }
    }

    assert_response :unprocessable_entity
    @investment.reload
    assert_not_equal "", @investment.name
  end

  test "should destroy investment" do
    assert_difference("Investment.count", -1) do
      delete portfolio_investment_url(@portfolio, @investment), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not allow access to other user's portfolio investments" do
    other_portfolio = portfolios(:trading)  # Belongs to users(:two)
    other_investment = investments(:gold_etf)

    get portfolio_investment_url(other_portfolio, other_investment)
    assert_response :not_found

    get edit_portfolio_investment_url(other_portfolio, other_investment)
    assert_response :not_found

    patch portfolio_investment_url(other_portfolio, other_investment), params: {
      investment: { name: "Hacked Investment" }
    }
    assert_response :not_found

    delete portfolio_investment_url(other_portfolio, other_investment)
    assert_response :not_found
  end

  test "should require authentication" do
    delete session_url  # Log out

    get new_portfolio_investment_url(@portfolio)
    assert_redirected_to new_session_url

    post portfolio_investments_url(@portfolio), params: {
      investment: { name: "Test Investment" }
    }
    assert_redirected_to new_session_url

    get portfolio_investment_url(@portfolio, @investment)
    assert_redirected_to new_session_url

    get edit_portfolio_investment_url(@portfolio, @investment)
    assert_redirected_to new_session_url

    patch portfolio_investment_url(@portfolio, @investment), params: {
      investment: { name: "Updated Investment" }
    }
    assert_redirected_to new_session_url

    delete portfolio_investment_url(@portfolio, @investment)
    assert_redirected_to new_session_url
  end
end
