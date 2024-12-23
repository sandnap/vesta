require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "email_validation_email" do
    mail = UserMailer.email_validation_email
    assert_equal "Email validation email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "support@optimalcadence.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
