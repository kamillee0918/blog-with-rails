class PostsController < ApplicationController
  before_action :authenticate_admin!, only: %i[ new create edit update destroy ]
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts
  def index
    @posts = Post.includes(:tags).order(published_at: :desc)
    @posts = @posts.published unless admin_signed_in?

    if params[:category].present?
      @category = params[:category]
      @posts = @posts.by_category(@category)
    end

    @posts = @posts.page(params[:page]).per(10)

    if admin_signed_in?
      set_no_cache_headers
    else
      fresh_when etag: @posts, last_modified: @posts.maximum(:updated_at)
    end

    # 페이지 파라미터가 있거나(1페이지 포함) 카테고리가 있으면 show_all 레이아웃으로 표시
    if params[:page].present? || @category.present?
      render :show_all
    end
  end

  # GET /search/:keyword
  def search
    @query = params[:keyword]
    base = admin_signed_in? ? Post : Post.published
    @posts = base.includes(:tags).search(@query).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/archive/:year
  def archive
    @year = params[:year].to_i
    base = admin_signed_in? ? Post : Post.published
    @posts = base.includes(:tags).by_year(@year).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/tag/:tag
  def tag
    @tag = params[:tag]
    base = admin_signed_in? ? Post : Post.published
    @posts = base.includes(:tags).by_tag(@tag).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/:id
  def show
    if admin_signed_in?
      set_no_cache_headers
    else
      return unless stale?(@post)
    end

    @recent_posts = Post.recent.limit(5)
    @archives = Post.yearly_archive_counts
    @caption = @post.cover_image_caption

    # 이전/다음 게시글 (published_at 기준)
    @prev_post = @post.previous_post
    @next_post = @post.next_post

    # 추천 게시글: 같은 태그를 가진 게시글 (최대 3개)
    @recommended_posts = @post.recommended_posts(limit: 3)
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

    def set_no_cache_headers
      response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, private"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "0"
    end

    # Only allow a list of trusted parameters through.
    def post_params
      permitted = params.expect(post: [ :title, :summary, :author, :tag_list, :published_at, :content, :cover_image, :slug, :category ])

      # 코드 블록 내용을 Base64로 인코딩하여 ActionText sanitizer를 우회
      if permitted[:content].present?
        permitted[:content] = encode_code_blocks(permitted[:content])
      end

      permitted
    end

    # <pre><code> 블록 내용 전체를 Base64로 인코딩
    # ActionText(Nokogiri)가 HTML 엔티티를 실제 HTML로 해석하는 것을 완전 방지
    # Base64는 영숫자+/+= 만 포함하므로 sanitizer가 간섭 불가
    def encode_code_blocks(html)
      html.gsub(%r{(<pre[^>]*>\s*<code[^>]*>)([\s\S]*?)(</code>\s*</pre>)}mi) do
        open_tags = $1
        code_content = $2
        close_tags = $3

        # 코드 블록 내용을 Base64로 인코딩 (UTF-8 지원)
        encoded = Base64.strict_encode64(code_content)

        "#{open_tags}BASE64:#{encoded}#{close_tags}"
      end
    end
end
