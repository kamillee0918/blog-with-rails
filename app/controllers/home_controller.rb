class HomeController < ApplicationController
  before_action :set_categories

  def index
    # Magazine Section: 최신 7개 발행된 포스트를 한 번에 로드하고 분리
    magazine_posts_data = Post.published.recent.limit(7).to_a

    # Magazine 포스트들을 미리 분리 (Ruby 레벨에서 처리)
    @center_post = magazine_posts_data.first
    @left_posts = magazine_posts_data[1..3] || []
    @right_posts = magazine_posts_data[4..6] || []

    # Featured Section: featured가 true인 발행된 포스트들
    @featured_posts = Post.published.featured.recent.to_a

    # Latest Section: 최신 8개 발행된 포스트
    @latest_posts = Post.published.recent.limit(8).to_a

    # "See all" 버튼 표시 여부 (전체 포스트가 latest보다 많을 때)
    total_count = Post.published.count
    displayed_count = @latest_posts.size
    @show_see_all = total_count > displayed_count

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
