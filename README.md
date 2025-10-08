# Blog with Rails 8

Rails 8 기반의 모던 블로그 애플리케이션입니다.

## 📋 프로젝트 개요

이 프로젝트는 Rails 8을 사용하여 구축된 블로그로, 다음 기능들을 포함합니다:

- ✅ **Phase 1**: 블로그 포스트 모델 (완료)
- 🚧 **Phase 2**: 블로그 레이아웃 구현 (예정)
- 🚧 **Phase 3**: 모달(팝업창) 기능 (예정)
- 🚧 **Phase 4**: 회원가입, 로그인 및 Magic Link 인증 (예정)

## 🛠️ 기술 스택

![Ruby Badge](https://img.shields.io/badge/-Ruby-CC342D?style=for-the-badge&labelColor=black&logo=ruby&logoColor=CC342D)
![Rails Badge](https://img.shields.io/badge/-Rails-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)

![Database Badge](https://img.shields.io/badge/-SQLite-003B57?style=for-the-badge&labelColor=black&logo=sqlite&logoColor=003B57)


![Turbo Badge](https://img.shields.io/badge/Turbo-5CD8E5?style=for-the-badge&labelColor=black&logo=turbo&logoColor=5CD8E5)
![Stimulus Badge](https://img.shields.io/badge/Stimulus-77E8B9?style=for-the-badge&labelColor=black&logo=stimulus&logoColor=77E8B9)

![CSS Badge](https://img.shields.io/badge/-Customized%20CSS-663399?style=for-the-badge&labelColor=black&logo=css&logoColor=663399)

## 📦 설치 및 실행

### 사전 요구사항

[![Ruby Version Badge](https://img.shields.io/badge/Ruby_INSTALLATION-3.4.5-CC342D?style=for-the-badge&labelColor=black&logo=ruby&logoColor=CC342D)](https://www.ruby-lang.org/ko/documentation/installation/)

[![Rails Version Badge](https://img.shields.io/badge/Rails_INSTALLATION-8.0.3-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)](https://rails.insomenia.com/install_ruby_on_rails)

### 설치

```bash
# 저장소 클론
git clone https://github.com/kamillee0918/blog-with-rails.git
cd ./blog

# 의존성 설치
bundle install

# 데이터베이스 생성 및 마이그레이션
bin/rails db:create db:migrate

# 샘플 데이터 로드
bin/rails db:seed
```

### 개발 서버 실행

```bash
bin/dev
```

브라우저에서 `http://localhost:3000` 접속

## 📊 데이터베이스 스키마

### Post 모델

| 필드 | 타입 | 설명 |
|------|------|------|
| title | string | 포스트 제목 (필수) |
| slug | string | URL 친화적 식별자 (필수, 유니크) |
| content | text | 포스트 본문 (필수) |
| excerpt | text | 포스트 요약 |
| category | string | 카테고리 (필수) |
| author_name | string | 작성자 이름 |
| author_avatar | string | 작성자 아바타 경로 |
| published_at | datetime | 발행 일시 |
| featured | boolean | 추천 포스트 여부 (기본값: false) |
| featured_image | string | 대표 이미지 경로 |
| image_caption | string | 이미지 캡션 |

**인덱스:**
- `slug` (unique)
- `published_at`
- `category`
- `featured`

## 🔍 주요 기능

### Post 모델 Scopes

```ruby
Post.published          # 발행된 포스트만
Post.featured           # 추천 포스트만
Post.by_category("AI")  # 특정 카테고리
Post.recent             # 최신순 정렬
```

### Post 모델 메서드

```ruby
post.published? # 발행 여부 확인
post.to_param   # SEO 친화적 URL (slug 반환)
```

## 📝 개발 가이드

### 레퍼런스

[![Ruby Reference Badge](https://img.shields.io/badge/Ruby_REFERENCE-3.4.5-CC342D?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=CC342D)](https://www.ruby-lang.org/ko/documentation/)
[![Ruby API Badge](https://img.shields.io/badge/Ruby_API-3.4.5-CC342D?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=CC342D)](https://docs.ruby-lang.org/en/3.4/)


[![Rails Reference Badge](https://img.shields.io/badge/Rails_REFERENCE-8.0.3-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)](https://rails.insomenia.com/)
[![Rails API Badge](https://img.shields.io/badge/Rails_API-8.0.3-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)](https://api.rubyonrails.org/)

### 코드 스타일

```bash
# RuboCop 실행
bin/rubocop

# 자동 수정
bin/rubocop -a
```

### 보안 스캔

```bash
# Brakeman 실행
bin/brakeman
```

## 📄 라이선스

This project is licensed under the MIT License.

## 👤 작성자

**Kamil Lee**

- GitHub: [@kamillee0918](https://github.com/kamillee0918)
