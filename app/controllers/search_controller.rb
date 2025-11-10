class SearchController < ApplicationController
  include CategoriesCacheable

  def index
    @query = params[:q]&.strip
    @category_filter = params[:category]&.strip

    if @query.present?
      # 기본 검색: published 포스트만
      @posts = Post.published.search(@query)

      # 카테고리 필터 적용
      @posts = @posts.by_category(@category_filter) if @category_filter.present?

      # 최신순 정렬 및 페이지네이션
      @posts = @posts.recent.limit(20)
    else
      @posts = []
    end

    respond_to do |format|
      format.html # 일반 HTML 응답
      format.json {
        render json: {
          query: @query,
          category: @category_filter,
          total: @posts.size,
          posts: @posts.map { |post| post_to_json(post) }
        }
      }
    end
  end

  private

  def post_to_json(post)
    {
      id: post.id,
      title: post.title,
      slug: post.slug,
      excerpt: post.excerpt&.truncate(120),
      category: post.category,
      author_name: post.author_name,
      published_at: post.published_at&.strftime("%Y-%m-%d"),
      reading_time: post.reading_time,
      path: post_by_slug_path(post.slug),
      featured_image: post.featured_image
    }
  end
end
