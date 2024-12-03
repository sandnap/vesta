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
        redirect_to settings_path, alert: "New password #{@user.errors.full_messages.join(", ")}"
      end
    else
      redirect_to settings_path, alert: "Current password is incorrect"
    end
  end

  private

    def password_params
      params.permit(:password, :password_confirmation)
    end
end
