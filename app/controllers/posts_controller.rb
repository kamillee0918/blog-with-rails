class PostsController < ApplicationController
  before_action :set_categories

  def index
    # 모든 포스트
    @posts = Post.published.recent.to_a

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        render json: {
          posts: @posts.map do |post|
            {
              title: post.title,
              slug: post.slug,
              excerpt: post.excerpt,
              category: post.category,
              author_name: post.author_name,
              author_avatar: post.author_avatar,
              author_avatar_url: author_avatar_url(post.author_avatar),
              author_url: post.author_url,
              author_bio: post.author_bio,
              author_social_url: post.author_social_url,
              published_at: post.published_at.strftime("%Y-%m-%d"),
              path: "/#{post.slug}"
            }
          end
        }
      end
    end
  end

  def show
    # 특정 포스트 조회
    @post_id = params[:slug]
    @post = Post.published.find_by!(slug: @post_id)

    # 블로그 포스트는 거의 변경되지 않으므로 캐싱 헤더 설정
    expires_in 1.hour, public: true
    fresh_when(@post, strong_etag: true)
  end

  private

  def set_categories
    # Footer용 모든 카테고리
    @categories = Post.published.distinct.pluck(:category).compact.sort
  end

  def author_avatar_url(avatar_filename)
    return nil if avatar_filename.blank?

    # View context의 asset_path 사용 (digest URL 생성)
    view_context.asset_path(avatar_filename)
  end
end
