# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    @all_tags = Post.pluck(:tags).compact.flat_map { |t| t.split(",").map(&:strip) }.reject(&:blank?).tally.sort_by { |_, count| -count }
    render status: :not_found
  end

  def unprocessable
    render status: :unprocessable_entity
  end

  def internal_server
    render status: :internal_server_error
  end
end
