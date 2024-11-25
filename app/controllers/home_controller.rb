class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    if authenticated?
      redirect_to portfolios_path
    else
      redirect_to new_session_path
    end
  end
end
