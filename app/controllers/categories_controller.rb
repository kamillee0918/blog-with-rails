class CategoriesController < ApplicationController
  before_action :set_categories

  def show
    @category_name = params[:name].upcase
    # N+1 쿼리 방지를 위해 includes(:user) 사용
    @posts = Post.published.includes(:user).by_category(@category_name).recent
  end

  private

  def set_categories
    @categories = Post.published.distinct.pluck(:category).compact.sort
  end
end
