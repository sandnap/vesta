require "test_helper"

class PortfoliosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @portfolio = portfolios(:retirement)
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"
    }
    assert_response :redirect
    follow_redirect!
  end

  test "should get index" do
    get portfolios_url
    assert_response :success
  end

  test "should get new" do
    get new_portfolio_url
    assert_response :success
  end

  test "should create portfolio" do
    assert_difference("Portfolio.count") do
      post portfolios_url, params: {
        portfolio: {
          name: "New Test Portfolio"
        }
      }
    end

    assert_redirected_to portfolio_url(Portfolio.last)
    assert_equal "Portfolio was successfully created.", flash[:notice]
  end

  test "should create portfolio with turbo stream" do
    assert_difference("Portfolio.count") do
      post portfolios_url, params: {
        portfolio: {
          name: "New Test Portfolio"
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not create portfolio with invalid params" do
    assert_no_difference("Portfolio.count") do
      post portfolios_url, params: {
        portfolio: {
          name: ""  # Name is required
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show portfolio" do
    get portfolio_url(@portfolio)
    assert_response :success
  end

  test "should get edit" do
    get edit_portfolio_url(@portfolio)
    assert_response :success
  end

  test "should update portfolio" do
    patch portfolio_url(@portfolio), params: {
      portfolio: {
        name: "Updated Portfolio Name"
      }
    }

    assert_redirected_to portfolio_url(@portfolio)
    assert_equal "Portfolio was successfully updated.", flash[:notice]
    @portfolio.reload
    assert_equal "Updated Portfolio Name", @portfolio.name
  end

  test "should update portfolio with turbo stream" do
    patch portfolio_url(@portfolio), params: {
      portfolio: {
        name: "Updated Portfolio Name"
      }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    @portfolio.reload
    assert_equal "Updated Portfolio Name", @portfolio.name
  end

  test "should not update portfolio with invalid params" do
    patch portfolio_url(@portfolio), params: {
      portfolio: {
        name: ""  # Name is required
      }
    }

    assert_response :unprocessable_entity
    @portfolio.reload
    assert_not_equal "", @portfolio.name
  end

  test "should destroy portfolio" do
    assert_difference("Portfolio.count", -1) do
      delete portfolio_url(@portfolio), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not allow access to other user's portfolio" do
    other_portfolio = portfolios(:trading)  # Belongs to users(:two)

    get portfolio_url(other_portfolio)
    assert_response :not_found

    get edit_portfolio_url(other_portfolio)
    assert_response :not_found

    patch portfolio_url(other_portfolio), params: {
      portfolio: { name: "Hacked Portfolio" }
    }
    assert_response :not_found

    delete portfolio_url(other_portfolio)
    assert_response :not_found
  end

  test "should require authentication" do
    delete session_url  # Log out

    get portfolios_url
    assert_redirected_to new_session_url

    get new_portfolio_url
    assert_redirected_to new_session_url

    post portfolios_url, params: {
      portfolio: { name: "Test Portfolio" }
    }
    assert_redirected_to new_session_url

    get portfolio_url(@portfolio)
    assert_redirected_to new_session_url

    get edit_portfolio_url(@portfolio)
    assert_redirected_to new_session_url

    patch portfolio_url(@portfolio), params: {
      portfolio: { name: "Updated Portfolio" }
    }
    assert_redirected_to new_session_url

    delete portfolio_url(@portfolio)
    assert_redirected_to new_session_url
  end
end
