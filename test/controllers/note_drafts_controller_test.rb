require "test_helper"

class NoteDraftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @portfolio = portfolios(:retirement)
    @investment = investments(:google_stock)
    @portfolio_draft = note_drafts(:portfolio_draft)
    @investment_draft = note_drafts(:investment_draft)

    # Log in
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"
    }
    assert_response :redirect
    follow_redirect!
  end

  test "should show portfolio draft" do
    get portfolio_note_draft_url(@portfolio, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @portfolio_draft.content, json["content"]
    assert_equal @portfolio_draft.importance, json["importance"]
  end

  test "should show investment draft" do
    get portfolio_investment_note_draft_url(@portfolio, @investment, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @investment_draft.content, json["content"]
    assert_equal @investment_draft.importance, json["importance"]
  end

  test "should create portfolio draft" do
    @portfolio_draft.destroy  # Ensure no draft exists

    assert_difference("NoteDraft.count") do
      post portfolio_note_draft_url(@portfolio, format: :json), params: {
        note_draft: {
          content: "New draft content",
          importance: 1
        }
      }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New draft content", json["content"]
    assert_equal 1, json["importance"]
  end

  test "should create investment draft" do
    @investment_draft.destroy  # Ensure no draft exists

    assert_difference("NoteDraft.count") do
      post portfolio_investment_note_draft_url(@portfolio, @investment, format: :json), params: {
        note_draft: {
          content: "New draft content",
          importance: 2
        }
      }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New draft content", json["content"]
    assert_equal 2, json["importance"]
  end

  test "should not create draft with invalid params" do
    @portfolio_draft.destroy  # Ensure no draft exists

    assert_no_difference("NoteDraft.count") do
      post portfolio_note_draft_url(@portfolio, format: :json), params: {
        note_draft: {
          content: "",  # Content is required
          importance: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should update portfolio draft" do
    patch portfolio_note_draft_url(@portfolio, format: :json), params: {
      note_draft: {
        content: "Updated draft content",
        importance: 2
      }
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated draft content", json["content"]
    assert_equal 2, json["importance"]
    @portfolio_draft.reload
    assert_equal "Updated draft content", @portfolio_draft.content
    assert_equal 2, @portfolio_draft.importance
  end

  test "should update investment draft" do
    patch portfolio_investment_note_draft_url(@portfolio, @investment, format: :json), params: {
      note_draft: {
        content: "Updated draft content",
        importance: 1
      }
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated draft content", json["content"]
    assert_equal 1, json["importance"]
    @investment_draft.reload
    assert_equal "Updated draft content", @investment_draft.content
    assert_equal 1, @investment_draft.importance
  end

  test "should not update draft with invalid params" do
    patch portfolio_note_draft_url(@portfolio, format: :json), params: {
      note_draft: {
        content: "",  # Content is required
        importance: 1
      }
    }

    assert_response :unprocessable_entity
    @portfolio_draft.reload
    assert_not_equal "", @portfolio_draft.content
  end

  test "should destroy portfolio draft" do
    assert_difference("NoteDraft.count", -1) do
      delete portfolio_note_draft_url(@portfolio, format: :json)
    end

    assert_response :no_content
  end

  test "should destroy investment draft" do
    assert_difference("NoteDraft.count", -1) do
      delete portfolio_investment_note_draft_url(@portfolio, @investment, format: :json)
    end

    assert_response :no_content
  end

  test "should not allow access to other user's drafts" do
    other_portfolio = portfolios(:trading)  # Belongs to users(:two)

    get portfolio_note_draft_url(other_portfolio, format: :json)
    assert_response :not_found

    post portfolio_note_draft_url(other_portfolio, format: :json), params: {
      note_draft: { content: "Hacked draft" }
    }
    assert_response :not_found

    patch portfolio_note_draft_url(other_portfolio, format: :json), params: {
      note_draft: { content: "Hacked draft" }
    }
    assert_response :not_found

    delete portfolio_note_draft_url(other_portfolio, format: :json)
    assert_response :not_found
  end

  test "should require authentication" do
    delete session_url  # Log out

    get portfolio_note_draft_url(@portfolio, format: :json)
    assert_redirected_to new_session_url

    post portfolio_note_draft_url(@portfolio, format: :json), params: {
      note_draft: { content: "Test draft" }
    }
    assert_redirected_to new_session_url

    patch portfolio_note_draft_url(@portfolio, format: :json), params: {
      note_draft: { content: "Updated draft" }
    }
    assert_redirected_to new_session_url

    delete portfolio_note_draft_url(@portfolio, format: :json)
    assert_redirected_to new_session_url
  end
end
