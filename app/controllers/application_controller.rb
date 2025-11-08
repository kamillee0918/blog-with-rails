class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Authenticatable

  # Global error handlers
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

    # Error handlers
    def not_found
      respond_to do |format|
        format.html { render file: Rails.root.join("public", "404.html"), status: :not_found, layout: false }
        format.json { render json: { error: "Not found" }, status: :not_found }
      end
    end

    def bad_request
      respond_to do |format|
        format.html { render file: Rails.root.join("public", "400.html"), status: :bad_request, layout: false }
        format.json { render json: { error: "Bad request" }, status: :bad_request }
      end
    end

    def unprocessable_entity
      respond_to do |format|
        format.html { render file: Rails.root.join("public", "422.html"), status: :unprocessable_entity, layout: false }
        format.json { render json: { error: "Unprocessable entity" }, status: :unprocessable_entity }
      end
    end
end
