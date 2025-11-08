# frozen_string_literal: true

Rswag::Api.configure do |c|
  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll also need to
  # ensure this path matches the openapi_root setting in swagger_helper.rb
  c.openapi_root = Rails.root.join("swagger").to_s
end
