# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Members::Api::Session API", type: :request do
  path "/members/api/session" do
    get "Get current session information" do
      tags "Members API", "Authentication"
      produces "application/json"
      description "Returns current session information including authentication status and user details"

      response "200", "authenticated session" do
        schema type: :object,
               properties: {
                 authenticated: { type: :boolean, example: true },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string, format: :email },
                     name: { type: :string },
                     verified: { type: :boolean }
                   },
                   required: %w[id email name verified]
                 },
                 identity: { type: :string, description: "Identity token for user verification" }
               },
               required: %w[authenticated]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("authenticated")
        end
      end

      response "200", "unauthenticated session" do
        schema type: :object,
               properties: {
                 authenticated: { type: :boolean, example: false },
                 identity: { type: :string, nullable: true }
               },
               required: %w[authenticated identity]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["authenticated"]).to eq(false)
          expect(data["identity"]).to be_nil
        end
      end
    end

    delete "Logout and destroy current session" do
      tags "Members API", "Authentication"
      produces "application/json"
      description "Destroys the current session and logs out the user"
      security [ { session_token: [] } ]

      response "200", "successfully logged out" do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: "Successfully logged out" }
               },
               required: %w[success message]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["success"]).to eq(true)
        end
      end

      response "401", "no active session" do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: false },
                 error: { type: :string, example: "No active session" }
               },
               required: %w[success error]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["success"]).to eq(false)
        end
      end
    end
  end
end
