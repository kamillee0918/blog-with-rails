class HomeController < ApplicationController
  before_action :set_categories

  def index
    # 필요한 컬럼만 선택하여 메모리 사용량 최적화
    post_columns = %i[id title slug excerpt category author_name author_avatar author_url
                      published_at featured featured_image image_caption created_at updated_at]

    # Magazine Section: 최신 7개 발행된 포스트
    magazine_posts_data = Post.published.recent.select(post_columns).limit(7).to_a

    # Magazine 포스트들을 미리 분리 (Ruby 레벨에서 처리)
    @center_post = magazine_posts_data.first
    @left_posts = magazine_posts_data[1..3] || []
    @right_posts = magazine_posts_data[4..6] || []

    # Featured Section: featured가 true인 발행된 포스트들
    @featured_posts = Post.published.featured.recent.select(post_columns).to_a

    # Latest Section: 최신 8개 발행된 포스트
    @latest_posts = Post.published.recent.select(post_columns).limit(8).to_a

    # "See all" 버튼 표시 여부 (효율적인 exists? 사용)
    @show_see_all = Post.published.offset(8).exists?

    # 홈페이지 캐싱 (새 포스트 발행 시까지 유효)
    expires_in 30.minutes, public: true
    fresh_when(etag: Post.published.maximum(:updated_at))
  end

  private

  def set_categories
    # Footer용 모든 카테고리
    @categories = Post.published.distinct.pluck(:category).compact.sort
  end
end
