require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @portfolio = portfolios(:retirement)
    @investment = investments(:google_stock)
    @portfolio_note = notes(:portfolio_note)
    @investment_note = notes(:investment_note)

    # Log in
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"
    }
    assert_response :redirect
    follow_redirect!
  end

  test "should get new for portfolio note" do
    get new_portfolio_note_url(@portfolio)
    assert_response :success
  end

  test "should get new for investment note" do
    get new_portfolio_investment_note_url(@portfolio, @investment)
    assert_response :success
  end

  test "should create portfolio note" do
    assert_difference("Note.count") do
      post portfolio_notes_url(@portfolio), params: {
        note: {
          content: "New portfolio note",
          importance: 1
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should create investment note" do
    assert_difference("Note.count") do
      post portfolio_investment_notes_url(@portfolio, @investment), params: {
        note: {
          content: "New investment note",
          importance: 1
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not create note with invalid params" do
    assert_no_difference("Note.count") do
      post portfolio_notes_url(@portfolio), params: {
        note: {
          content: "",  # Content is required
          importance: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit for portfolio note" do
    get edit_portfolio_note_url(@portfolio, @portfolio_note)
    assert_response :success
  end

  test "should get edit for investment note" do
    get edit_portfolio_investment_note_url(@portfolio, @investment, @investment_note)
    assert_response :success
  end

  test "should update portfolio note" do
    patch portfolio_note_url(@portfolio, @portfolio_note), params: {
      note: {
        content: "Updated portfolio note",
        importance: 2
      }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    @portfolio_note.reload
    assert_equal "Updated portfolio note", @portfolio_note.content
    assert_equal 2, @portfolio_note.importance
  end

  test "should update investment note" do
    patch portfolio_investment_note_url(@portfolio, @investment, @investment_note), params: {
      note: {
        content: "Updated investment note",
        importance: 2
      }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    @investment_note.reload
    assert_equal "Updated investment note", @investment_note.content
    assert_equal 2, @investment_note.importance
  end

  test "should not update note with invalid params" do
    patch portfolio_note_url(@portfolio, @portfolio_note), params: {
      note: {
        content: "",  # Content is required
        importance: 1
      }
    }

    assert_response :unprocessable_entity
    @portfolio_note.reload
    assert_not_equal "", @portfolio_note.content
  end

  test "should destroy portfolio note" do
    assert_difference("Note.count", -1) do
      delete portfolio_note_url(@portfolio, @portfolio_note), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should destroy investment note" do
    assert_difference("Note.count", -1) do
      delete portfolio_investment_note_url(@portfolio, @investment, @investment_note), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should not allow access to other user's notes" do
    other_portfolio = portfolios(:trading)  # Belongs to users(:two)
    other_note = notes(:portfolio_note_two)

    get edit_portfolio_note_url(other_portfolio, other_note)
    assert_response :not_found

    patch portfolio_note_url(other_portfolio, other_note), params: {
      note: { content: "Hacked note" }
    }
    assert_response :not_found

    delete portfolio_note_url(other_portfolio, other_note)
    assert_response :not_found
  end

  test "should require authentication" do
    delete session_url  # Log out

    get new_portfolio_note_url(@portfolio)
    assert_redirected_to new_session_url

    post portfolio_notes_url(@portfolio), params: {
      note: { content: "Test note" }
    }
    assert_redirected_to new_session_url

    get edit_portfolio_note_url(@portfolio, @portfolio_note)
    assert_redirected_to new_session_url

    patch portfolio_note_url(@portfolio, @portfolio_note), params: {
      note: { content: "Updated note" }
    }
    assert_redirected_to new_session_url

    delete portfolio_note_url(@portfolio, @portfolio_note)
    assert_redirected_to new_session_url
  end
end
