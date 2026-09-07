require "test_helper"

class CodeBlockEscapingTest < ActiveSupport::TestCase
  # 저장 파이프라인이 코드 블록을 Base64 로 감싸므로, 테스트도 같은 모양으로 만든다.
  def encoded_block(code, language: "java")
    %(<pre class="language-#{language}"><code>BASE64:#{Base64.strict_encode64(code)}</code></pre>)
  end

  def plain_block(code, language: "java")
    %(<pre class="language-#{language}"><code>#{code}</code></pre>)
  end

  def create_post(body, **attrs)
    # content= 로 넣으면 Action Text 를 거치므로, 저장된 바이트를 우리가 통제하려고
    # 자리를 만든 뒤 컬럼에 직접 써 둔다. 실제 손상도 이 컬럼 안에서 일어난다.
    @seq = (@seq || 0) + 1
    post = Post.create!({ title: "Code Post #{@seq}", category: "Test", published_at: 1.day.ago,
                          content: "<p>placeholder</p>" }.merge(attrs))
    write_body(post, body)
    post
  end

  def write_body(post, body)
    sql = ActiveRecord::Base.sanitize_sql_array(
      [ "UPDATE action_text_rich_texts SET body = ? WHERE id = ?", body, post.content.id ]
    )
    ActiveRecord::Base.connection.exec_update(sql)
    post.reload
  end

  def stored_body(post)
    post.content.reload.read_attribute_before_type_cast("body").to_s
  end

  def decoded_blocks(post)
    stored_body(post).scan(%r{<code>BASE64:([A-Za-z0-9+/=]+)</code>}).flatten
                     .map { |e| Base64.strict_decode64(e) }
  end

  # === 탐지 ===

  test "덧붙은 이스케이프를 깊이에 상관없이 센다" do
    {
      "&amp;lt;" => 1,               # 이중
      "&amp;amp;lt;" => 1,           # 삼중
      "&amp;amp;amp;lt;" => 1,       # 4중
      "&amp;amp;amp;amp;lt;" => 1    # 5중
    }.each do |entity, expected|
      body = encoded_block("if (a #{entity} b) {}")
      assert_equal expected, CodeBlockEscaping.over_escapes(body),
                   "#{entity} 를 세지 못했다"
    end
  end

  test "정상적으로 이스케이프된 코드는 지적하지 않는다" do
    body = encoded_block("for (int i = 0; i &lt; N; i++) if (a &amp;&amp; b) {}")

    assert_equal 0, CodeBlockEscaping.over_escapes(body)
  end

  test "코드 블록 밖의 엔티티는 세지 않는다" do
    body = "<p>산문에서는 &amp;amp; 가 정상일 수 있다</p>" + encoded_block("int a = 1;")

    assert_equal 0, CodeBlockEscaping.over_escapes(body)
  end

  test "Base64 로 감싸지 않은 코드 블록도 본다" do
    body = plain_block("if (a &amp;amp;lt; b) {}")

    assert_equal 1, CodeBlockEscaping.over_escapes(body)
  end

  # === 복구 ===

  test "깊이가 다른 여러 블록을 한 번에 깊이 0 으로 되돌린다" do
    post = create_post(
      encoded_block("a &amp;lt; b") +
      encoded_block("c &amp;amp;amp;gt; d")
    )

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_equal [ "a &lt; b", "c &gt; d" ], decoded_blocks(post)
    assert_equal 0, CodeBlockEscaping.over_escapes(stored_body(post))
  end

  test "정상적인 && 를 망가뜨리지 않는다" do
    post = create_post(encoded_block("if (x &amp;amp;amp;&amp;amp;amp; y &amp;amp;lt; z) {}"))

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_equal [ "if (x &amp;&amp; y &lt; z) {}" ], decoded_blocks(post)
  end

  test "멱등하다 — 이미 정상인 본문은 건드리지 않는다" do
    body = encoded_block("for (int i = 0; i &lt; N; i++) {}")
    post = create_post(body)

    result = CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_equal 0, result.posts
    assert_equal body, stored_body(post), "바꿀 것이 없는데 본문이 바뀌었다"
  end

  test "두 번 돌려도 결과가 같다" do
    post = create_post(encoded_block("a &amp;amp;lt; b"))

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))
    once = stored_body(post)
    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_equal once, stored_body(post)
  end

  test "산문의 인라인 code 스팬은 건드리지 않는다" do
    prose = "<p>정수 이분 탐색은 <code>while (hi - lo &gt; 1)</code> 이 표준이다</p>"
    post = create_post(prose + encoded_block("a &amp;amp;lt; b"))

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_includes stored_body(post), prose
  end

  test "Base64 가 깨진 블록은 원문 그대로 둔다" do
    # 디코딩에 실패한다고 예외를 던지면 글 한 건 때문에 전체 복구가 멈춘다.
    broken = %(<pre class="language-java"><code>BASE64:!!!not-base64!!!</code></pre>)
    post = create_post(broken + encoded_block("a &amp;amp;lt; b"))

    assert_nothing_raised do
      CodeBlockEscaping.repair(scope: Post.where(id: post.id))
    end
    assert_includes stored_body(post), broken
    assert_equal [ "a &lt; b" ], decoded_blocks(post)
  end

  test "Base64 로 감싸지 않은 블록도 복구한다" do
    post = create_post(plain_block("a &amp;amp;lt; b"))

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_includes stored_body(post), "a &lt; b"
  end

  # === 부수 효과 ===

  test "dry_run 은 셈만 하고 저장하지 않는다" do
    body = encoded_block("a &amp;amp;lt; b")
    post = create_post(body)

    result = CodeBlockEscaping.repair(scope: Post.where(id: post.id), dry_run: true)

    assert_equal 1, result.posts
    assert_equal 1, result.fixes
    assert_equal body, stored_body(post), "dry_run 인데 본문이 바뀌었다"
  end

  test "고친 글은 touch 한다 — 그러지 않으면 ETag 가 그대로라 독자가 옛 페이지를 본다" do
    post = create_post(encoded_block("a &amp;amp;lt; b"), updated_at: 1.week.ago)
    before = post.updated_at

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_operator post.reload.updated_at, :>, before
  end

  test "바꿀 것이 없는 글은 touch 하지 않는다" do
    post = create_post(encoded_block("a &lt; b"), updated_at: 1.week.ago)
    before = post.updated_at

    CodeBlockEscaping.repair(scope: Post.where(id: post.id))

    assert_equal before.to_i, post.reload.updated_at.to_i
  end

  test "결과에 게시글 수와 수정 곳 수가 담긴다" do
    a = create_post(encoded_block("x &amp;amp;lt; y &amp;amp;gt; z"))
    b = create_post(encoded_block("p &amp;lt; q"))
    create_post(encoded_block("이미 &lt; 정상"))

    result = CodeBlockEscaping.repair(scope: Post.where(id: [ a.id, b.id ]))

    assert_equal 2, result.posts
    assert_equal 3, result.fixes
  end

  test "본문이 없는 글에서도 죽지 않는다" do
    post = Post.create!(title: "No Body", category: "Test", published_at: 1.day.ago)

    assert_nothing_raised do
      CodeBlockEscaping.repair(scope: Post.where(id: post.id))
    end
  end
end
