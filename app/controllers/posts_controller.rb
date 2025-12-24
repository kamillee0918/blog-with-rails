class PostsController < ApplicationController
  before_action :authenticate_admin!, only: %i[ new create edit update destroy ]
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts
  def index
    @posts = Post.order(published_at: :desc)

    if params[:category].present?
      @category = params[:category]
      @posts = @posts.by_category(@category)
    end

    @posts = @posts.page(params[:page]).per(10)

    # HTTP 캐싱: 최신 게시글 기준으로 캐시 유효성 검증
    latest_post = @posts.first
    cache_key = [ latest_post&.cache_key_with_version, params[:page], params[:category] ]
    fresh_when(etag: cache_key, last_modified: latest_post&.updated_at)
    response.headers["Cache-Control"] = "public, no-cache"

    # 페이지 파라미터가 있거나(1페이지 포함) 카테고리가 있으면 show_all 레이아웃으로 표시
    if params[:page].present? || @category.present?
      render :show_all
    end
  end

  # GET /search/:keyword
  def search
    @query = params[:keyword]
    @posts = Post.search(@query).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/archive/:year
  def archive
    @year = params[:year].to_i
    @posts = Post.by_year(@year).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/tag/:tag
  def tag
    @tag = params[:tag]
    @posts = Post.by_tag(@tag).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/:id
  def show
    # HTTP 캐싱: ETag/Last-Modified 기반 조건부 GET
    # 게시글이 변경되지 않았으면 304 Not Modified 반환
    if stale?(etag: @post, last_modified: @post.updated_at, public: true)
      @recent_posts = Post.recent.limit(5)
      @archives = Post.yearly_archive_counts
      @caption = @post.cover_image_caption

      # 이전/다음 게시글 (published_at 기준)
      @prev_post = @post.previous_post
      @next_post = @post.next_post

      # 추천 게시글: 같은 태그를 가진 게시글 (최대 3개)
      @recommended_posts = @post.recommended_posts(limit: 3)

      # 캐시 헤더: 항상 서버에 재검증 요청 (ETag 활용)
      response.headers["Cache-Control"] = "public, no-cache"
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # slug 또는 id로 Post 조회 (영어 제목은 slug, 한국어 제목은 id)
    def set_post
      @post = Post.find_by_slug_or_id!(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :summary, :author, :tags, :published_at, :content, :cover_image, :slug, :category ])
    end
end
