class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.email_validation_email.subject
  #
  def email_validation_email
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
