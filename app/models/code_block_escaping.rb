# frozen_string_literal: true

# 코드 블록 안에서 자라나는 이스케이프를 탐지하고 되돌린다.
#
# 글을 저장할 때마다 <pre><code> 안의 엔티티에 이스케이프가 한 겹씩 덧붙는다.
# `&lt;` → `&amp;lt;` → `&amp;amp;lt;` … 브라우저는 덧붙은 겹을 문자로 그리므로,
# 독자에게는 `<` 대신 `&amp;lt;` 라는 글자가 보인다. 2026-09-07 에 발행글 7건에서
# 197 곳을 발견했고 깊이가 저장 횟수를 따라 자라 있었다 — 한 번만 저장한 글에도
# 이미 한 겹 붙어 있었다.
#
# 산문의 인라인 <code> 스팬은 멀쩡하다. PostsController#encode_code_blocks 의
# Base64 파이프라인을 타는 <pre><code> 블록에서만 일어난다.
#
# 이것은 지혈이지 완치가 아니다. 원인을 고치기 전까지는 글을 저장할 때마다
# 되살아나므로, 글을 손본 뒤에는 `rake content:fix_escaping` 을 다시 돌려야 한다.
# 남아 있는 손상은 `rake content:check` 가 오류로 잡는다.
#
# 로직을 rake task 안이 아니라 여기 두는 이유는 테스트를 붙이기 위해서다.
module CodeBlockEscaping
  Result = Struct.new(:posts, :fixes, :entries, keyword_init: true)
  Entry = Struct.new(:post, :count, :before, :after, keyword_init: true)

  # 한 겹 이상 덧붙은 것만 고른다. `&lt;` 는 정상이고 `&amp;lt;` 부터가 손상이다.
  OVER = /&(?:amp;)+(?:lt|gt|amp);/
  # 깊이가 얼마든 한 번에 깊이 0 으로 되돌린다. `&amp;amp;amp;` 는 `&amp;` 가
  # 되어야 하므로(코드의 `&&`), 마지막 한 겹은 남긴다.
  NORMALIZE = /&(?:amp;)*(lt|gt|amp);/
  # <pre><code> … </code></pre> 한 덩어리. 산문의 인라인 <code> 는 걸리지 않는다.
  BLOCK = %r{(<pre[^>]*>\s*<code[^>]*>)(.*?)(</code>\s*</pre>)}mi
  # encode_code_blocks 가 감싸 둔 형태.
  PAYLOAD = %r{\A\s*BASE64:([A-Za-z0-9+/=]+)\s*\z}

  class << self
    # 본문에 남아 있는 덧붙은 이스케이프의 개수. 0 이어야 정상이다.
    def over_escapes(body)
      body.to_s.scan(BLOCK).sum { |_open, inner, _close| decode(inner).scan(OVER).size }
    end

    # 손상된 글을 찾아 되돌린다. 멱등하므로 반복 실행해도 안전하다.
    def repair(scope: Post.all, dry_run: false)
      entries = scope.includes(:rich_text_content).filter_map do |post|
        repair_post(post, dry_run: dry_run)
      end

      Result.new(posts: entries.size, fixes: entries.sum(&:count), entries: entries)
    end

    private
      def repair_post(post, dry_run:)
        rich = post.content
        return nil if rich.nil?

        raw = rich.read_attribute_before_type_cast("body").to_s
        return nil if raw.empty?

        count = 0
        before = nil
        after = nil

        fixed = raw.gsub(BLOCK) do
          open = Regexp.last_match(1)
          inner = Regexp.last_match(2)
          close = Regexp.last_match(3)

          payload = decode(inner)
          found = payload.scan(OVER).size
          next "#{open}#{inner}#{close}" if found.zero?

          count += found
          normalized = normalize(payload)
          before ||= sample(payload)
          after ||= sample(normalized)
          "#{open}#{wrap(inner, normalized)}#{close}"
        end

        return nil if count.zero?

        unless dry_run
          write(rich, fixed)
          # 본문만 바뀌면 posts.updated_at 이 그대로라 ETag 와 cache_version 이
          # 움직이지 않는다. 그러면 독자는 고치기 전 페이지를 계속 받는다.
          post.touch
        end

        Entry.new(post: post, count: count, before: before, after: after)
      end

      def decode(inner)
        encoded = inner[PAYLOAD, 1]
        return inner if encoded.nil?

        Base64.strict_decode64(encoded)
      rescue ArgumentError
        # 디코딩이 안 되는 블록 하나 때문에 나머지 복구가 멈추면 안 된다.
        # Post#rendered_content 도 같은 이유로 원문을 그대로 둔다.
        inner
      end

      def wrap(inner, normalized)
        inner.match?(PAYLOAD) ? "BASE64:#{Base64.strict_encode64(normalized)}" : normalized
      end

      def normalize(payload)
        payload.gsub(NORMALIZE) { "&#{Regexp.last_match(1)};" }
      end

      def sample(payload)
        line = payload.each_line.find { |l| l.match?(/&(?:amp;)*(?:lt|gt);/) }
        line.to_s.strip.truncate(72)
      end

      # Action Text 를 거치지 않고 컬럼에 바이트 그대로 쓴다. 지금 되돌리는 것이
      # 본문을 다시 직렬화하는 과정에서 생긴 손상이므로, 복구하는 길에서 같은
      # 과정을 한 번 더 태울 이유가 없다.
      def write(rich, body)
        sql = ActiveRecord::Base.sanitize_sql_array(
          [ "UPDATE action_text_rich_texts SET body = ?, updated_at = ? WHERE id = ?",
            body, Time.current, rich.id ]
        )
        ActiveRecord::Base.connection.exec_update(sql)
      end
  end
end
