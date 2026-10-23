require "test_helper"

# 코드 블록이 저장 왕복을 거쳐도 바이트 하나 바뀌지 않는지 서버 쪽에서 확인한다.
#
# 에디터 쪽(init.js)은 script/check_code_block_roundtrip.mjs 가 본다. 여기서는 TinyMCE 가
# 보내는 형태의 본문을 실제 요청으로 저장하고 다시 저장해, PostsController#encode_code_blocks →
# Action Text 파싱·살균 → Post#rendered_content 디코딩이 한 바퀴 돌아도 같은지 본다.
# 2026-09-07 의 손상은 저장할 때마다 `&lt;` 에 한 겹씩 붙는 형태였으므로, 재저장을 반복한다.
class CodeBlockRoundtripTest < ActionDispatch::IntegrationTest
  CODE_HTML = %(&lt;div class="note"&gt;a &amp;amp; b &amp;lt; c&lt;/div&gt;\n&lt;script&gt;alert(1)&lt;/script&gt;)
  CODE_RUBY = %(if a &amp;&amp; b &lt; 3\n  puts "&lt;ok&gt;"\nend)
  BODY = <<~HTML
    <p>본문 산문 &lt;tag&gt; 와 <code>&lt;inline&gt;</code></p>
    <pre class="language-markup"><code>#{CODE_HTML}</code></pre>
    <pre class="language-ruby"><code>#{CODE_RUBY}</code></pre>
  HTML
  OVER_ESCAPED = /&(?:amp;)+(?:lt|gt|amp);/

  setup { sign_in_as_admin }

  def post_params
    { post: { title: "Roundtrip", summary: "코드 블록 왕복 검사용 요약 " * 3, category: "Tech",
              published_at: 1.day.ago, content: BODY } }
  end

  def snapshot(post)
    post.reload
    [ post.content.body_before_type_cast.to_s, post.rendered_content.to_s ]
  end

  test "코드 블록은 저장할 때 Base64 로 감싸이고 렌더링에서 원문 그대로 돌아온다" do
    post posts_url, params: post_params
    stored, rendered = snapshot(Post.order(:id).last)

    assert_equal 2, stored.scan("BASE64:").size
    assert_includes rendered, CODE_HTML
    assert_includes rendered, CODE_RUBY
    assert_equal BODY.scan(OVER_ESCAPED).size, rendered.scan(OVER_ESCAPED).size, "이스케이프가 덧붙었다"
  end

  test "같은 본문을 두 번 다시 저장해도 저장된 body 와 렌더링 결과가 바뀌지 않는다" do
    post posts_url, params: post_params
    record = Post.order(:id).last
    first = snapshot(record)

    2.times do
      patch post_url(record), params: post_params
      assert_equal first, snapshot(record)
    end
  end

  test "공개 페이지에도 코드 블록이 원문 그대로 나온다" do
    post posts_url, params: post_params
    get post_url(Post.order(:id).last)

    assert_response :success
    assert_includes response.body, CODE_HTML
    assert_includes response.body, CODE_RUBY
  end
end
