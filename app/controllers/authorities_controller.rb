class AuthoritiesController < ApplicationController
  before_action :set_categories

  def show
    @author_slug = params[:name].downcase
    @posts = Post.published.by_author_slug(@author_slug).recent
    @author_avatar = @posts.first&.author_avatar
    @author_url = @posts.first&.author_url
    @author_bio = @posts.first&.author_bio
    @author_social_url = safe_url(@posts.first&.author_social_url)

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

  def safe_url(url)
    return nil if url.blank?
    return url if url.start_with?("http://", "https://")

    nil
  end
end
