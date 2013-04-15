class UserMailer < ActionMailer::Base

  require 'mail'
  address = Mail::Address.new "mailbot@vcdelta.org"
  address.display_name = "VCDelta"

  default from: address.format

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @account_activation_url = activate_user_url(user.activation_token)
    mail to: user.email, subject: "ACTION NEEDED: Activate your VCDelta.org account"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = user
    @password_reset_url = edit_password_reset_url(user.reset_password_token)
    mail to: user.email, subject: "Reset your VCDelta.org password"
  end
end
