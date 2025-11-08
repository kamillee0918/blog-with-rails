# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured, as per the Readme, to route requests to the
  # appropriate Swagger files.
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Kamil Lee's Blog API",
        version: "v1",
        description: "API documentation for Kamil Lee's development blog built with Rails 8",
        contact: {
          name: "Kamil Lee",
          email: "lazaronixon@hotmail.com"
        }
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        },
        {
          url: "https://{defaultHost}",
          variables: {
            defaultHost: {
              default: "www.example.com"
            }
          },
          description: "Production server"
        }
      ],
      components: {
        securitySchemes: {
          session_token: {
            type: :apiKey,
            name: "session_token",
            in: :cookie,
            description: "Session token stored in signed cookie"
          }
        },
        schemas: {
          error_object: {
            type: :object,
            properties: {
              success: { type: :boolean, example: false },
              error: { type: :string, example: "Error message" }
            }
          },
          post: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              slug: { type: :string },
              content: { type: :string },
              excerpt: { type: :string },
              category: { type: :string },
              author_name: { type: :string },
              author_avatar: { type: :string },
              published_at: { type: :string, format: "date-time", nullable: true },
              featured: { type: :boolean },
              featured_image: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id title slug]
          },
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string, format: :email },
              nickname: { type: :string },
              verified: { type: :boolean },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id email verified]
          },
          session: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              user_agent: { type: :string, nullable: true },
              ip_address: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id user_id]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
