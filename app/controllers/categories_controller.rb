class CategoriesController < ApplicationController
  before_action :set_categories

  def show
    @category_name = params[:name].upcase
    @posts = Post.published.by_category(@category_name).recent
  end

  private

  def set_categories
    @categories = Post.published.distinct.pluck(:category).compact.sort
  end
end
