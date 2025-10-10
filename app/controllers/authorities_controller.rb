class AuthoritiesController < ApplicationController
  before_action :set_categories

  def show
    @author_slug = params[:name].downcase
    @posts = Post.published.by_author_slug(@author_slug).recent

    # Get full author name from the first post (for display)
    @author_name = @posts.first&.author_name || @author_slug.capitalize
    @page_title = "Posts by #{@author_name}"

    # 404 if no posts found for this author
    redirect_to root_path, alert: "Author not found" if @posts.empty?
  end

  private

  def set_categories
    @categories = Post.published.distinct.pluck(:category).compact.sort
  end
end
