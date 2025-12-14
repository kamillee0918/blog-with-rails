# frozen_string_literal: true

# Action Text HTML Sanitizer 설정
# TinyMCE 에디터에서 사용하는 테이블 및 추가 HTML 태그를 허용합니다.
#
# 참고: Action Text는 기본적으로 보안을 위해 특정 HTML 태그만 허용합니다.
# 테이블 태그 등을 사용하려면 명시적으로 허용 목록에 추가해야 합니다.
#
# Rails 7.1+에서는 allowed_tags/allowed_attributes가 기본값 nil이므로
# 명시적으로 설정해야 합니다.

Rails.application.config.after_initialize do
  # 이미지 관련 태그 허용
  image_tags = %w[
    svg
  ]

  # 테이블 관련 태그 허용
  table_tags = %w[
    table
    thead
    tbody
    tfoot
    tr
    th
    td
    caption
  ]

  # 테이블 및 기타 요소에 필요한 속성 허용
  table_attributes = %w[
    colspan
    rowspan
    scope
    headers
    border
    cellpadding
    cellspacing
    width
    height
    align
    valign
  ]

  link_attributes = %w[
    data-turbo
  ]

  # Rails 7.1+ 호환: nil 체크 후 설정
  if ActionText::ContentHelper.allowed_tags.nil?
    # 기본 허용 태그 + 테이블 태그 설정
    ActionText::ContentHelper.allowed_tags = Rails::HTML5::Sanitizer.safe_list_sanitizer.allowed_tags + image_tags + table_tags
  else
    ActionText::ContentHelper.allowed_tags += image_tags + table_tags
  end

  if ActionText::ContentHelper.allowed_attributes.nil?
    # 기본 허용 속성 + 테이블 속성 설정
    ActionText::ContentHelper.allowed_attributes = Rails::HTML5::Sanitizer.safe_list_sanitizer.allowed_attributes + table_attributes + link_attributes
  else
    ActionText::ContentHelper.allowed_attributes += table_attributes + link_attributes
  end
end
