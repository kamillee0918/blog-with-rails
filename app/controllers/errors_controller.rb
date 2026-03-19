# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    @all_tags = Tag.popular_with_counts(10)
    render status: :not_found
  end

  def unprocessable
    render status: :unprocessable_entity
  end

  def internal_server
    render status: :internal_server_error
  end
end
