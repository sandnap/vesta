require "test_helper"

class PortfoliosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get portfolios_index_url
    assert_response :success
  end

  test "should get show" do
    get portfolios_show_url
    assert_response :success
  end

  test "should get new" do
    get portfolios_new_url
    assert_response :success
  end

  test "should get edit" do
    get portfolios_edit_url
    assert_response :success
  end
end
