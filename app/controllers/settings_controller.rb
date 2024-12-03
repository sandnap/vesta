class SettingsController < ApplicationController
  def show
    @user = Current.user
  end

  def update_password
    @user = Current.user
    if @user.authenticate(params[:current_password])
      if @user.update(password_params)
        redirect_to settings_path, notice: "Password successfully updated"
      else
        redirect_to settings_path, alert: "#{@user.errors.full_messages.join(", ")}"
      end
    else
      redirect_to settings_path, alert: "Current password is incorrect"
    end
  end

  def disable_user
    @user = Current.user
    @user.update(disabled: true, email_address: "#{@user.email_address}-disabled-#{Time.current.to_i}")
    terminate_session
    redirect_to new_session_path, notice: "Your account has been disabled."
  end

  private

    def password_params
      params.permit(:password, :password_confirmation)
    end
end
