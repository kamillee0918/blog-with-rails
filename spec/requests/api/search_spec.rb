# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Search API", type: :request do
  path "/search" do
    get "Search blog posts" do
      tags "Search"
      produces "application/json"
      description "Search for blog posts by query and optionally filter by category"

      parameter name: :q, in: :query, type: :string, required: false, description: "Search query"
      parameter name: :category, in: :query, type: :string, required: false, description: "Category filter"

      response "200", "successful" do
        schema type: :object,
               properties: {
                 query: { type: :string, nullable: true },
                 category: { type: :string, nullable: true },
                 total: { type: :integer },
                 posts: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       slug: { type: :string },
                       excerpt: { type: :string, nullable: true },
                       category: { type: :string },
                       author_name: { type: :string },
                       published_at: { type: :string, format: :date, nullable: true },
                       reading_time: { type: :integer },
                       path: { type: :string },
                       featured_image: { type: :string, nullable: true }
                     },
                     required: %w[id title slug category author_name reading_time path]
                   }
                 }
               },
               required: %w[total posts]

        let(:q) { "Rails" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["total"]).to be >= 0
          expect(data["posts"]).to be_an(Array)
        end
      end

      response "200", "empty query returns empty results" do
        let(:q) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["total"]).to eq(0)
          expect(data["posts"]).to eq([])
        end
      end
    end
  end
end
