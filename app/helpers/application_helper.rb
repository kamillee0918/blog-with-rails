module ApplicationHelper
  # 레이아웃이 CDN에서 받아오는 Prism/Mermaid/MathJax는 합쳐 수백 KB에 달하므로
  # 페이지가 실제로 쓰는 것만 로드한다.
  # 뷰에서 require_content_libraries로 표시하고 레이아웃이 content_library?로 읽는다.
  def require_content_libraries(*libraries)
    libraries.flatten.each { |library| content_for :"needs_#{library}", "1" }
  end

  def content_library?(library)
    content_for?(:"needs_#{library}")
  end

  # 게시글 본문 HTML을 보고 필요한 라이브러리를 판별한다.
  # 애매하면 로드하는 쪽을 택한다 — 잘못 로드하면 느려질 뿐이지만
  # 빠뜨리면 수식이나 다이어그램이 아예 렌더링되지 않는다.
  def content_libraries_for(html)
    html = html.to_s
    libraries = []
    libraries << :prism if html.match?(/<(?:pre|code)\b/i)
    libraries << :mermaid if html.match?(/<pre[^>]*\bmermaid\b/i)
    libraries << :mathjax if math_delimiters?(html)
    libraries
  end

  # MathJax 설정이 구분자로 $…$ 와 $$…$$ 만 등록하므로 그 두 가지만 찾는다.
  # <pre>/<code> 내부는 MathJax의 skipHtmlTags 기본값이 건너뛰는 영역이라
  # 검사 전에 제거해 셸 예제($HOME 등)로 인한 오탐을 줄인다.
  def math_delimiters?(html)
    text = html.gsub(%r{<(pre|code)\b.*?</\1>}mi, " ")
    text.include?("$$") || text.match?(/\$[^$\s][^$\n]*\$/)
  end
end
