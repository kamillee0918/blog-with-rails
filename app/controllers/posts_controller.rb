class PostsController < ApplicationController
  before_action :authenticate_admin!, only: %i[ new create edit update destroy ]
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts
  def index
    @posts = listing_scope.order(published_at: :desc)

    if params[:category].present?
      @category = params[:category]
      @posts = @posts.by_category(@category)
    end

    @posts = @posts.page(params[:page]).per(10)

    if admin_signed_in?
      set_no_cache_headers
    else
      # relation 을 그대로 etag 로 넘기면 안 된다. Relation#cache_key 는 to_sql 의
      # 다이제스트를 포함하는데, published 스코프가 문자열 조건이라 Time.current 가
      # SQL 에 마이크로초까지 리터럴로 박힌다. 그러면 내용이 그대로여도 요청마다
      # ETag 가 달라져 304 가 영영 나오지 않는다.
      # cache_version(레코드 수 + 최신 updated_at)과 응답을 가르는 파라미터만 쓴다.
      # last_modified 는 함께 보내지 않는다. 두 검증자를 모두 주면 둘 다 일치해야
      # 304 가 되는데, 페이지네이션된 relation 의 maximum(:updated_at)은 LIMIT/OFFSET
      # 때문에 2페이지부터 nil 이라 헤더가 빠진다.
      #
      # fresh_when 이 아니라 stale? 을 쓰는 이유는 아래 render 때문이다. 둘 다 신선하면
      # 304 를 렌더하지만 액션을 중단하지는 않는다. category/page 가 붙은 요청은 그
      # 뒤에서 show_all 을 한 번 더 렌더하게 되어 DoubleRenderError 로 500 이 났다.
      # 파라미터 없는 /posts 는 두 번째 렌더가 없어 멀쩡했고, 그래서 오래 눈에 띄지 않았다.
      return unless stale?(etag: [ @posts.cache_version, params[:category], params[:page] ])
    end

    # 페이지 파라미터가 있거나(1페이지 포함) 카테고리가 있으면 show_all 레이아웃으로 표시
    if params[:page].present? || @category.present?
      render :show_all
    end
  end

  # GET /search/:keyword
  def search
    @query = params[:keyword]
    @posts = listing_scope.search(@query).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/archive/:year
  def archive
    @year = params[:year].to_i
    @posts = listing_scope.by_year(@year).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/tag/:tag
  def tag
    @tag = params[:tag]
    @posts = listing_scope.by_tag(@tag).recent.page(params[:page]).per(8)
    render :show_all
  end

  # GET /posts/:id
  def show
    if admin_signed_in?
      set_no_cache_headers
    else
      return unless stale?(@post)
    end

    @recent_posts = post_scope.recent.limit(5)
    @archives = post_scope.yearly_archive_counts
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
      @post = post_scope.find_by_slug_or_id!(params[:id])
    end

    # 미공개(예약) 게시글은 관리자에게만 보인다.
    def post_scope
      admin_signed_in? ? Post.all : Post.published
    end

    # 목록 카드가 쓰는 연관을 한 번에 로드해 N+1을 제거한다.
    # - tags:        태그 배지
    # - cover_image: 썸네일 variant URL 생성
    # 본문(rich_text_content)은 더 이상 적재하지 않는다. 카드가 본문에서 쓰던 값은
    # read_time 뿐이었는데 이제 posts.word_count 로 대체돼, 목록 한 페이지마다
    # 본문 수백 KB를 끌어오던 비용이 사라졌다.
    def listing_scope
      post_scope.includes(:tags).with_attached_cover_image
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
