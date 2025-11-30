class PostsController < ApplicationController
  before_action :authenticate_admin!, only: %i[ new create edit update destroy ]
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.order(published_at: :desc)

    if params[:category].present?
      @category = params[:category]
      @posts = @posts.by_category(@category)
    end

    @posts = @posts.page(params[:page]).per(10)

    # 페이지 파라미터가 있거나(1페이지 포함) 카테고리가 있으면 show_all 레이아웃으로 표시
    if params[:page].present? || @category.present?
      render :show_all
    end
  end

  # GET /search/:keyword
  def search
    @query = params[:keyword]
    if @query.present?
      @posts = Post.where("title LIKE ? OR summary LIKE ? OR tags LIKE ?",
                          "%#{@query}%", "%#{@query}%", "%#{@query}%")
                   .order(published_at: :desc)
                   .page(params[:page]).per(8)
    else
      @posts = Post.none.page(params[:page]).per(8)
    end
    render :show_all
  end

  # GET /posts/archive/:year
  def archive
    @year = params[:year].to_i
    @posts = Post.where("strftime('%Y', published_at) = ?", @year.to_s)
                 .order(published_at: :desc)
                 .page(params[:page]).per(8)

    render :show_all
  end

  # GET /posts/1 or /posts/1.json
  def show
    @recent_posts = Post.order(published_at: :desc).limit(5)
    @archives = Post.group("strftime('%Y', published_at)").count
    @caption = @post.cover_image.attached? ? @post.cover_image.metadata[:caption] : ""

    # 이전/다음 게시글 (published_at 기준)
    @prev_post = Post.where("published_at < ?", @post.published_at).order(published_at: :desc).first
    @next_post = Post.where("published_at > ?", @post.published_at).order(published_at: :asc).first

    # 추천 게시글: 같은 태그를 가진 게시글 (최대 3개)
    if @post.tags.present?
      post_tags = @post.tags.split(",").map(&:strip)
      @recommended_posts = Post.where.not(id: @post.id)
                               .where("tags IS NOT NULL AND tags != ''")
                               .select { |p| (p.tags.split(",").map(&:strip) & post_tags).any? }
                               .first(3)
    else
      @recommended_posts = []
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find_by!(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :summary, :author, :tags, :published_at, :content, :cover_image, :slug, :category ])
    end
end
