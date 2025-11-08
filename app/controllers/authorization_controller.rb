class AuthorizationController < ApplicationController
  def index
    respond_to do |format|
      format.json # JSON 응답
    end
  end
end
