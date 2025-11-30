class ArticlesController < ApplicationController
  # GET /articles
  def index
    @posts = Post.order(published_at: :desc).page(params[:page])
  end
end
