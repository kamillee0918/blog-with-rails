class CategoriesController < ApplicationController
  include CategoriesCacheable

  def show
    @category_name = params[:name].upcase
    # N+1 쿼리 방지를 위해 includes(:user) 사용
    @posts = Post.published.includes(:user).by_category(@category_name).recent
  end
end
