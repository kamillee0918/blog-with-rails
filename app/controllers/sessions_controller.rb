class SessionsController < ApplicationController
  def new
    if admin_signed_in?
      redirect_to root_path, notice: "Already logged in."
    end
  end

  def create
    # Simple password check. In production, use a robust environment variable or credentials.
    admin_password = ENV["ADMIN_PASSWORD"] || "password"

    if params[:password] == admin_password
      session[:admin_id] = "admin"
      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_path, notice: "Logged out."
  end
end
