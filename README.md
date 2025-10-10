# Blog with Rails 8

Rails 8 기반의 모던 블로그 애플리케이션입니다.

## 📋 프로젝트 개요

이 프로젝트는 Rails 8을 사용하여 구축된 모던 블로그로, 다음 기능들을 포함합니다:

- ✅ **Phase 1**: 블로그 포스트 모델 (완료)
- ✅ **Phase 2**: 블로그 레이아웃 구현 (완료)
- 🚧 **Phase 3**: 모달(팝업창) 기능 (예정)
- 🚧 **Phase 4**: 회원가입, 로그인 및 Magic Link 인증 (예정)
- 🚧 **Phase 5**: 블로그 모바일 레이아웃 구현 (예정)

### 🎯 Phase 2 주요 기능
- **📱 반응형 매거진 레이아웃**: Center/Side/Latest 포스트 배치
- **🎨 문법 하이라이팅**: PrismJS + Turbo 호환성
- **🧮 수식 렌더링**: MathJax v4 통합
- **⚡ 성능 최적화**: HTTP 캐싱, Turbo Drive
- **🖼️ 반응형 이미지**: srcset을 활용한 최적화
- **🔍 SEO 친화적**: 구조화된 메타데이터

## 🛠️ 기술 스택

### 백엔드
![Ruby Badge](https://img.shields.io/badge/-Ruby-CC342D?style=for-the-badge&labelColor=black&logo=ruby&logoColor=CC342D)
![Rails Badge](https://img.shields.io/badge/-Rails-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)
![Database Badge](https://img.shields.io/badge/-SQLite-003B57?style=for-the-badge&labelColor=black&logo=sqlite&logoColor=003B57)

### 프론트엔드
![Turbo Badge](https://img.shields.io/badge/Turbo-5CD8E5?style=for-the-badge&labelColor=black&logo=turbo&logoColor=5CD8E5)
![Stimulus Badge](https://img.shields.io/badge/Stimulus-77E8B9?style=for-the-badge&labelColor=black&logo=stimulus&logoColor=77E8B9)
![CSS Badge](https://img.shields.io/badge/-Customized%20CSS-663399?style=for-the-badge&labelColor=black&logo=css&logoColor=663399)

### 외부 라이브러리
![PrismJS Badge](https://img.shields.io/badge/-PrismJS-FFFFFF?style=for-the-badge&labelColor=black&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyMDAgMTcwIj48cGF0aCBmaWxsPSIjZmZmIiBkPSJNNTUuMzcgMTMxLjVINDguNHY5LjEzaDYuOTdjMS42NyAwIDIuOTItLjQgMy43OC0xLjIyLjg1ICAtLjggMS4yOC0xLjkyIDEuMjgtMy4zM3MtLjQzLTIuNTQtMS4yOC0zLjM1Yy0uODYtLjgtMi4xMi0xLjItMy43OC0xLjJtMjkuNTIgIDYuNGMuMy0uNTMuNDctMS4yLjQ3LTIuMDQgMC0xLjM1LS40NS0yLjQtMS4zNy0zLjItLjkyLS43Ni0yLjE0LTEuMTUtMy42NSAgLTEuMTVINzIuOXY4LjUyaDcuMzJjMi4yNiAwIDMuODItLjcgNC42Ny0yLjFNMTAwIDBMMCAxNzBoMjAwTDEwMCAwTTYwLjg2ICAxNDEuMDNjLTEuMyAxLjIyLTMuMSAxLjg0LTUuMzMgMS44NEg0OC40djcuNTVINDZ2LTIxLjJoOS41M2MyLjI0IDAgNC4wMi42MyAgNS4zNCAxLjg3IDEuMyAxLjIzIDEuOTYgMi44OCAxLjk2IDQuOTUgMCAyLjEtLjY2IDMuNzUtMS45NyA0Ljk4bTI0LjUgOS40bCAgLTUuMS04LjE0aC03LjM3djguMTJoLTIuNHYtMjEuMmgxMC4xNGMyLjE1IDAgMy44OC42IDUuMTggMS44IDEuMyAxLjE4IDEuOTUgIDIuOCAxLjk1IDQuODQgMCAyLjY0LTEuMSA0LjQ0LTMuMyA1LjQtLjYuMjgtMS4yMi41LTEuODIuNmw1LjU3IDguNTZoLTIuODVtICAxMy40MyAwaC0yLjR2LTIxLjJoMi40djIxLjJtMjMuNTYtMS4zMmMtMS40OCAxLjA1LTMuNTMgMS41Ny02LjE2IDEuNTctMi45NiAwICAtNS4yMy0uNi02Ljc4LTEuODUtMS40LTEuMS0yLjE4LTIuNy0yLjM3LTQuNzRoMi41Yy4wOCAxLjQ1Ljc4IDIuNTYgMi4xIDMuMzMgIDEuMTYuNjcgMi42OCAxIDQuNTggMSAzLjk3IDAgNS45NS0xLjI1IDUuOTUtMy43NCAwLS44Ni0uMzUtMS41My0xLjA3LTIuMDItLjcgIC0uNS0xLjYtLjktMi42OC0xLjItMS4wNy0uMzMtMi4yNC0uNjMtMy40OC0uOXMtMi40LS42NS0zLjUtMS4wOC0xLjk3LTEuMDIgIC0yLjY4LTEuNzNjLS43LS43Mi0xLjA3LTEuNjgtMS4wNy0yLjkgMC0xLjczLjY1LTMuMTMgMS45Ny00LjIyIDEuMzItMS4wOCAgMy4zMi0xLjYyIDYtMS42MiAyLjY3IDAgNC43NS42IDYuMjMgMS44NSAxLjM0IDEuMSAyLjA1IDIuNSAyLjE0IDQuMmgtMi40NmMgIC0uMjItMS43Ni0xLjM1LTIuOTItMy40LTMuNS0uNzItLjItMS42Mi0uMy0yLjctLjNzLTEuOTguMS0yLjcyLjM1Yy0uNzQuMjUgIC0xLjMuNTUtMS43LjktLjQyLjM1LS43Ljc0LS44MyAxLjE3cy0uMi44OC0uMiAxLjM2YzAgLjUuMi45My42MiAxLjMzcy45Ni43NSAgMS42NSAxLjAzYy42OC4yOCAxLjQ2LjUyIDIuMzMuNzMuODguMiAxLjc3LjQzIDIuNjcuNjUuOS4yMiAxLjguNDggMi42OC43Ny44NyAgLjMgMS42NS42NSAyLjMzIDEuMSAxLjUzLjk2IDIuMjggMi4yNyAyLjI4IDMuOTQgMCAyLS43NCAzLjUtMi4yMiA0LjU1bTI4Ljg0ICAxLjMydi0xNy41NGwtNy44NCAxMC4wOC03Ljk3LTEwLjA4djE3LjU0SDEzM3YtMjEuMmgyLjc4bDcuNTggMTAuMDYgNy40NSAgLTEwLjA1aDIuOHYyMS4yaC0yLjQiLz48L3N2Zz4=&logoColor=FFFFFF)
![MathJax Badge](https://img.shields.io/badge/-MathJax-2E9F40?style=for-the-badge&labelColor=black&logo=data:image/png%2Bxml;base64,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&logoColor=4ECDC4)



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
