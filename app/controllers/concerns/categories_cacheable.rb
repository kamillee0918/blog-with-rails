# frozen_string_literal: true

# Concern for caching categories list across multiple controllers
# This prevents redundant database queries on every page request
module CategoriesCacheable
  extend ActiveSupport::Concern

  included do
    before_action :set_categories
  end

  private

  def set_categories
    # Cache categories list for 1 hour
    # Cache will be invalidated when a post's category changes
    @categories = Rails.cache.fetch("categories_list", expires_in: 1.hour) do
      Post.published.distinct.pluck(:category).compact.sort
    end
  end
end
