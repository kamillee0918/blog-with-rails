# Blog with Rails 8

Rails 8 기반의 모던 블로그 애플리케이션입니다.

## ️ 기술 스택

### 백엔드

![Ruby Badge](https://img.shields.io/badge/-Ruby-CC342D?style=for-the-badge&labelColor=black&logo=ruby&logoColor=CC342D)
![Rails Badge](https://img.shields.io/badge/-Rails-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)
![Database Badge](https://img.shields.io/badge/-SQLite-003B57?style=for-the-badge&labelColor=black&logo=sqlite&logoColor=003B57)
![PostgreSQL Badge](https://img.shields.io/badge/-PostgreSQL-4169E1?style=for-the-badge&labelColor=black&logo=postgresql&logoColor=4169E1)

### 프론트엔드

![Turbo Badge](https://img.shields.io/badge/Turbo-5CD8E5?style=for-the-badge&labelColor=black&logo=turbo&logoColor=5CD8E5)
![Stimulus Badge](https://img.shields.io/badge/Stimulus-77E8B9?style=for-the-badge&labelColor=black&logo=stimulus&logoColor=77E8B9)
![CSS Badge](https://img.shields.io/badge/-Customized%20CSS-663399?style=for-the-badge&labelColor=black&logo=css&logoColor=663399)

### 인프라

![Docker Badge](https://img.shields.io/badge/-Docker-2496ED?style=for-the-badge&labelColor=black&logo=docker&logoColor=2496ED)
![Kamal Badge](https://img.shields.io/badge/-Kamal-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)
![Supabase Badge](https://img.shields.io/badge/-Supabase-3FCF8E?style=for-the-badge&labelColor=black&logo=supabase&logoColor=3FCF8E)

### 외부 라이브러리

![TinyMCE Badge](https://img.shields.io/badge/-TinyMCE-10a37f?style=for-the-badge&labelColor=black&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iIzEwYTM3ZiIgZD0iTTMgM2gxOHYxOEgzVjN6bTIgMnYxNGgxNFY1SDV6bTIgM2gxMHYySDd2LTJ6bTAgNGgxMHYySDd2LTJ6bTAgNGg2djJIN3YtMnoiLz48L3N2Zz4=)

![PrismJS Badge](https://img.shields.io/badge/-PrismJS-FFFFFF?style=for-the-badge&labelColor=black&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyMDAgMTcwIj48cGF0aCBmaWxsPSIjZmZmIiBkPSJNNTUuMzcgMTMxLjVINDguNHY5LjEzaDYuOTdjMS42NyAwIDIuOTItLjQgMy43OC0xLjIyLjg1ICAtLjggMS4yOC0xLjkyIDEuMjgtMy4zM3MtLjQzLTIuNTQtMS4yOC0zLjM1Yy0uODYtLjgtMi4xMi0xLjItMy43OC0xLjJtMjkuNTIgIDYuNGMuMy0uNTMuNDctMS4yLjQ3LTIuMDQgMC0xLjM1LS40NS0yLjQtMS4zNy0zLjItLjkyLS43Ni0yLjE0LTEuMTUtMy42NSAgLTEuMTVINzIuOXY4LjUyaDcuMzJjMi4yNiAwIDMuODItLjcgNC42Ny0yLjFNMTAwIDBMMCAxNzBoMjAwTDEwMCAwTTYwLjg2ICAxNDEuMDNjLTEuMyAxLjIyLTMuMSAxLjg0LTUuMzMgMS44NEg0OC40djcuNTVINDZ2LTIxLjJoOS41M2MyLjI0IDAgNC4wMi42MyAgNS4zNCAxLjg3IDEuMyAxLjIzIDEuOTYgMi44OCAxLjk2IDQuOTUgMCAyLjEtLjY2IDMuNzUtMS45NyA0Ljk4bTI0LjUgOS40bCAgLTUuMS04LjE0aC03LjM3djguMTJoLTIuNHYtMjEuMmgxMC4xNGMyLjE1IDAgMy44OC42IDUuMTggMS44IDEuMyAxLjE4IDEuOTUgIDIuOCAxLjk1IDQuODQgMCAyLjY0LTEuMSA0LjQ0LTMuMyA1LjQtLjYuMjgtMS4yMi41LTEuODIuNmw1LjU3IDguNTZoLTIuODVtICAxMy40MyAwaC0yLjR2LTIxLjJoMi40djIxLjJtMjMuNTYtMS4zMmMtMS40OCAxLjA1LTMuNTMgMS41Ny02LjE2IDEuNTctMi45NiAwICAtNS4yMy0uNi02Ljc4LTEuODUtMS40LTEuMS0yLjE4LTIuNy0yLjM3LTQuNzRoMi41Yy4wOCAxLjQ1Ljc4IDIuNTYgMi4xIDMuMzMgIDEuMTYuNjcgMi42OCAxIDQuNTggMSAzLjk3IDAgNS45NS0xLjI1IDUuOTUtMy43NCAwLS44Ni0uMzUtMS41My0xLjA3LTIuMDItLjcgIC0uNS0xLjYtLjktMi42OC0xLjItMS4wNy0uMzMtMi4yNC0uNjMtMy40OC0uOXMtMi40LS42NS0zLjUtMS4wOC0xLjk3LTEuMDIgIC0yLjY4LTEuNzNjLS43LS43Mi0xLjA3LTEuNjgtMS4wNy0yLjkgMC0xLjczLjY1LTMuMTMgMS45Ny00LjIyIDEuMzItMS4wOCAgMy4zMi0xLjYyIDYtMS42MiAyLjY3IDAgNC43NS42IDYuMjMgMS44NSAxLjM0IDEuMSAyLjA1IDIuNSAyLjE0IDQuMmgtMi40NmMgIC0uMjItMS43Ni0xLjM1LTIuOTItMy40LTMuNS0uNzItLjItMS42Mi0uMy0yLjctLjNzLTEuOTguMS0yLjcyLjM1Yy0uNzQuMjUgIC0xLjMuNTUtMS43LjktLjQyLjM1LS43Ljc0LS44MyAxLjE3cy0uMi44OC0uMiAxLjM2YzAgLjUuMi45My42MiAxLjMzcy45Ni43NSAgMS42NSAxLjAzYy42OC4yOCAxLjQ2LjUyIDIuMzMuNzMuODguMiAxLjc3LjQzIDIuNjcuNjUuOS4yMiAxLjguNDggMi42OC43Ny44NyAgLjMgMS42NS42NSAyLjMzIDEuMSAxLjUzLjk2IDIuMjggMi4yNyAyLjI4IDMuOTQgMCAyLS43NCAzLjUtMi4yMiA0LjU1bTI4Ljg0ICAxLjMydi0xNy41NGwtNy44NCAxMC4wOC03Ljk3LTEwLjA4djE3LjU0SDEzM3YtMjEuMmgyLjc4bDcuNTggMTAuMDYgNy40NSAgLTEwLjA1aDIuOHYyMS4yaC0yLjQiLz48L3N2Zz4=&logoColor=FFFFFF)
![MathJax Badge](https://img.shields.io/badge/-MathJax-2E9F40?style=for-the-badge&labelColor=black&logo=data:image/png%2Bxml;base64,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&logoColor=4ECDC4)

## 📦 설치 및 실행

### 사전 요구사항

[![Ruby Version Badge](https://img.shields.io/badge/Ruby_INSTALLATION-3.4.5-CC342D?style=for-the-badge&labelColor=black&logo=ruby&logoColor=CC342D)](https://www.ruby-lang.org/ko/documentation/installation/)

[![Rails Version Badge](https://img.shields.io/badge/Rails_INSTALLATION-8.1.3-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)](https://rails.insomenia.com/install_ruby_on_rails)

### 설치

```bash
# 저장소 클론
git clone https://github.com/kamillee0918/blog-with-rails.git
cd blog-with-rails

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

| 필드           | 타입       | 설명                            |
| -------------- | ---------- | ------------------------------- |
| title          | string     | 포스트 제목 (필수)              |
| summary        | text       | 포스트 요약                     |
| content        | rich_text  | 포스트 본문 (Action Text)       |
| author         | string     | 작성자 이름                     |
| published_at   | datetime   | 발행 일시                       |
| slug           | string     | URL 슬러그 (제목에서 자동 생성) |
| category       | string     | 카테고리                        |
| cover_image    | attachment | 대표 이미지 (ActiveStorage)     |

### Tag 모델

| 필드 | 타입   | 설명                          |
| ---- | ------ | ----------------------------- |
| name | string | 태그명 (소문자 정규화, unique) |

- Post ↔ Tag: `has_and_belongs_to_many` (조인 테이블: `posts_tags`)

### 주요 메서드

```ruby
# 인스턴스 메서드
post.read_time              # 읽는 시간 (최소 1분)
post.cover_image_caption    # 커버 이미지 캡션
post.previous_post          # 이전 게시글 (published만)
post.next_post              # 다음 게시글 (published만)
post.recommended_posts      # 같은 태그 추천 게시글
post.tag_list               # 태그 목록 (getter/setter)
post.rendered_content       # 코드 블록 디코딩 HTML

# 스코프
Post.published              # 발행된 게시글만
Post.recent                 # 최신순 정렬
Post.search(query)          # 제목/요약/본문 검색
Post.by_tag(name)           # 태그별 필터링
```

## 🔍 주요 기능

- **TinyMCE 에디터**: 드래그&드롭 이미지 업로드, Turbo 호환 초기화
- **관리자 인증**: 세션 기반 로그인, Brute Force Protection (5회 제한, 15분 잠금)
- **태그 시스템**: 정규화된 다대다 관계 (자동 소문자 변환)
- **HTTP 캐싱**: ETag 기반 `stale?`/`fresh_when` 조건부 GET
- **보안**: Content Security Policy (report-only), 보안 헤더
- **반응형 이미지**: srcset 기반 최적화 (7단계 해상도)
- **검색**: 실시간 검색 모달 + Stimulus 컨트롤러
- **코드 하이라이팅**: PrismJS + Turbo 호환
- **수식 렌더링**: MathJax v4 통합

## 🔐 환경 변수

| 변수 | 용도 | 필수 환경 |
|------|------|----------|
| `ADMIN_PASSWORD` | 관리자 로그인 비밀번호 | production |
| `TINYMCE_API_KEY` | TinyMCE Cloud API 키 | all |
| `DATABASE_URL` | PostgreSQL 접속 URL | production |

## 📝 개발 가이드

### 코드 품질 체크

```bash
# 푸시 전 종합 체크 (Brakeman + RuboCop + Tests)
bin/check-code

# 개별 실행
bin/brakeman         # 보안 스캔
bin/rubocop          # 코드 스타일
bin/rubocop -a       # 자동 수정
bin/rails test       # 테스트
```

### 데이터베이스 구조

| 환경 | DB | 용도 |
|------|-----|------|
| development / test | SQLite | 로컬 개발 |
| production | PostgreSQL (Supabase) | 운영 |
| cache / queue / cable | SQLite | 모든 환경 (Solid Cache/Queue/Cable) |

### 배포

Kamal + Docker 기반으로 배포합니다.

```bash
# 배포 전 검증
bin/check-code

# Kamal 배포
kamal deploy
```

### 레퍼런스

[![Ruby Reference Badge](https://img.shields.io/badge/Ruby_REFERENCE-3.4.5-CC342D?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=CC342D)](https://www.ruby-lang.org/ko/documentation/)
[![Ruby API Badge](https://img.shields.io/badge/Ruby_API-3.4.5-CC342D?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=CC342D)](https://docs.ruby-lang.org/en/3.4/)

[![Rails Reference Badge](https://img.shields.io/badge/Rails_REFERENCE-8.1.3-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)](https://rails.insomenia.com/)
[![Rails API Badge](https://img.shields.io/badge/Rails_API-8.1.3-D30001?style=for-the-badge&labelColor=black&logo=rubyonrails&logoColor=D30001)](https://api.rubyonrails.org/)

## 📄 라이선스

This project is licensed under the MIT License.

## 👤 작성자

**Kamil Lee**

- GitHub: [@kamillee0918](https://github.com/kamillee0918)
