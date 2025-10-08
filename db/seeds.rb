# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
Post.destroy_all

posts_data = [
  {
    title: "Gumbel AlphaZero 04: 핵심 정리와 구현 체크리스트",
    slug: "2025-09-19-gumbel-alphazero-04",
    content: "AI 시리즈 4편: 핵심 메커니즘 종합, 하이퍼파라미터 가이드, 복잡도/이론적 보장, 실전 적용 팁.",
    excerpt: "Gumbel AlphaZero의 전체 흐름과 구현 시 꼭 확인할 체크리스트를 정리합니다.",
    category: "AI",
    author_name: "Kamil Lee",
    author_avatar: "profile.png",
    published_at: 3.day.ago,
    featured: false,
    featured_image: "thumbnail/gumbel_alphazero_thumbnail.png",
    image_caption: "Gumbel AlphaZero 04: 핵심 정리와 구현 체크리스트"
  },
  {
    title: "Gumbel AlphaZero 03: 정책 학습 — Completed Q-values",
    slug: "2025-09-08-gumbel-alphazero-03",
    content: "AI 시리즈 3편: Completed Q-values, Mixed Value(혼합 가치), 정규화/스케일링과 목표 정책 생성.",
    excerpt: "방문하지 않은 행동까지 포함한 완성된 Q값으로 이론적 정책 새선을 달성.",
    category: "AI",
    author_name: "Kamil Lee",
    author_avatar: "profile.png",
    published_at: 14.day.ago,
    featured: false,
    featured_image: "thumbnail/gumbel_alphazero_thumbnail.png",
    image_caption: "Gumbel AlphaZero 03: 정책 학습 — Completed Q-values"
  },
  {
    title: "Gumbel AlphaZero 02: 행동 선택 — Gumbel-Top-k & Sequential Halving",
    slug: "2025-09-04-gumbel-alphazero-02",
    content: "AI 시리즈 2편: Gumbel-Max/Top-k, Sequential Halving, 루트/내부 노드 행동 선택 전략과 코드.",
    excerpt: "Gumbel-Top-k로 후보 선정, Sequential Halving으로 자원 배분, 루트/내부 노드의 이원화 전략.",
    category: "AI",
    author_name: "Kamil Lee",
    author_avatar: "profile.png",
    published_at: 18.day.ago,
    featured: false,
    featured_image: "thumbnail/gumbel_alphazero_thumbnail.png",
    image_caption: "Gumbel AlphaZero 02: 행동 선택 — Gumbel-Top-k & Sequential Halving"
  },
  {
    title: "Gumbel AlphaZero 01: 소개 및 기본 탐색 알고리즘",
    slug: "2025-09-02-gumbel-alphazero-01",
    content: "AI 시리즈 1편: DeepMind Mctx(JAX) 환경 구성, visualization_demo.py로 탐색 트리 이해, 기존 AlphaZero의 한계 요약.",
    excerpt: "Mctx 설치/설정과 visualization_demo.py로 Gumbel MuZero 탐색을 직관적으로 살펴봅니다.",
    category: "AI",
    author_name: "Kamil Lee",
    author_avatar: "profile.png",
    published_at: 20.day.ago,
    featured: true,
    featured_image: "thumbnail/gumbel_alphazero_thumbnail.png",
    image_caption: "Gumbel AlphaZero 01: 소개 및 기본 탐색 알고리즘"
  },
  {
    title: "CPU 스케줄러",
    slug: "2025-04-30-cpu-scheduler",
    content: "CS 시리즈 1편: CPU 스케줄링 개요, 스케줄링의 역할과 작동 시점, 디스패처와 컨텍스트 스위칭.",
    excerpt: "CPU 스케줄링 개요, 스케줄링의 역할과 작동 시점, 디스패처와 컨텍스트 스위칭.",
    category: "CS",
    author_name: "Kamil Lee",
    author_avatar: "profile.png",
    published_at: 154.day.ago,
    featured: true,
    featured_image: "thumbnail/cpu_scheduler_thumbnail.png",
    image_caption: "CPU 스케줄러"
  }
]

# Create posts
posts_data.each do |post_attrs|
  Post.find_or_create_by!(slug: post_attrs[:slug]) do |post|
    post.assign_attributes(post_attrs)
  end
end

puts "Created #{Post.count} posts"