class PostsController < ApplicationController
  before_action :set_categories

  def index
    # 모든 포스트
    @posts = Post.published.recent.to_a
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
end
