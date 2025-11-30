### 💡 기능 요약

**[Refactor]: 심플 블로그 아키텍처로 전면 리팩토링**

기존 복잡한 인증 시스템(Magic Link, OTP)을 제거하고, Tailwind CSS 기반의 심플하고 현대적인 블로그 아키텍처로 전환합니다. Action Text, Active Storage, Kaminari를 통합하여 게시물 관리 기능을 강화합니다.

### 🛠️ 구현 계획

### 1. 인증 시스템 제거

- **User/Session 모델 삭제**: 관련 마이그레이션, 테스트 전체 제거
- **Magic Link/OTP 서비스 삭제**: AuthenticationService, OTPService 제거
- **관련 컨트롤러 삭제**: RegistrationsController, SessionsController, AuthorizationController 등
- **UserMailer 삭제**: 이메일 인증 관련 메일러 제거

### 2. 프론트엔드 스택 변경

- **Ghost 테마 CSS 제거**: application.css, cards.css, root.css, screen.css, sub.css
- **Tailwind CSS 도입**: site.css, style.min.css, tailwind.config.js
- **새 웹폰트 추가**: Salesforce Sans, Lato, Avant Garde

### 3. 게시물 관리 기능 강화

- **Action Text 통합**: Rich Text 에디터로 게시물 작성
- **Active Storage 통합**: 이미지/파일 업로드 시스템
- **Kaminari 추가**: 게시물 페이지네이션
- **CRUD 인터페이스**: 게시물 생성/수정/삭제 뷰 추가

### 4. 데이터베이스 스키마 변경

- **Post 모델 확장**: slug, category, tags 필드 추가
- **마이그레이션 정리**: 기존 인증 관련 마이그레이션 제거, 새 스키마 적용

### 🔥 우선순위

🔴 높음 - 배포 전 필수 (아키텍처 전면 변경)

### 📋 구현 체크리스트

### 1. 인증 시스템 제거

- [ ] User, Session 모델 및 관련 마이그레이션 삭제
- [ ] MagicLinkService, OTPService 삭제
- [ ] RegistrationsController, AuthorizationController 삭제
- [ ] UserMailer 및 이메일 템플릿 삭제
- [ ] 관련 테스트 파일 삭제
- [ ] Stimulus 컨트롤러 정리 (authorization_controller.js, members_controller.js 등)

### 2. 프론트엔드 스택 변경

- [ ] Ghost 테마 CSS 파일 삭제
- [ ] Tailwind CSS 설정 및 스타일시트 추가
- [ ] 새 웹폰트 파일 추가 (Salesforce Sans, Lato, Avant Garde)
- [ ] 레이아웃 템플릿 업데이트 (application.html.erb)

### 3. 게시물 관리 기능 강화

- [ ] Action Text 마이그레이션 및 설정
- [ ] Active Storage 마이그레이션 및 설정
- [ ] Kaminari 설치 및 뷰 템플릿 추가
- [ ] 게시물 CRUD 뷰 생성 (_form, edit, new, search)
- [ ] ArticlesController, ThumbnailsController 추가

### 4. 데이터베이스 및 설정

- [ ] Post 모델에 slug, category, tags 필드 추가 마이그레이션
- [ ] db/schema.rb 업데이트
- [ ] seeds.rb 업데이트
- [ ] config/routes.rb 라우팅 구조 단순화
- [ ] Gemfile 의존성 업데이트

### 5. 테스트 및 문서화

- [ ] 기존 테스트 정리 및 새 테스트 작성
- [ ] README.md 업데이트
- [ ] CI 워크플로우 업데이트

### 📝 추가 정보 및 고려사항

**BREAKING CHANGES**:

⚠️ **인증 시스템 완전 제거**:
- 기존 사용자 데이터가 있다면 마이그레이션 전 백업 필요
- 로그인/회원가입 기능 없이 공개 블로그로 운영

⚠️ **스타일링 시스템 변경**:
- Ghost 테마 기반 CSS → Tailwind CSS
- 기존 CSS 클래스명 호환성 없음

**주요 변경 파일**:

```
삭제:
├── app/models/user.rb, session.rb
├── app/controllers/*auth*, *session*, *registration*
├── app/services/authentication/*
├── app/mailers/user_mailer.rb
├── app/assets/stylesheets/application.css, cards.css, root.css, screen.css, sub.css
├── db/migrate/*users*, *sessions*
└── test/*auth*, *user*, *session*

추가:
├── app/assets/stylesheets/site.css, style.min.css
├── app/assets/tailwind/
├── app/assets/fonts/salesforce-sans-*, lato-*, avant-garde.woff2
├── app/controllers/articles_controller.rb, thumbnails_controller.rb
├── app/views/posts/_form, edit, new, search
├── app/views/kaminari/
├── config/tailwind.config.js
└── db/migrate/*action_text*, *active_storage*, *tags*, *slug*
```

**기술 스택 변경**:

| 구분 | Before | After |
|------|--------|-------|
| 인증 | Magic Link + OTP | 없음 (공개 블로그) |
| CSS | Ghost 테마 기반 | Tailwind CSS |
| 에디터 | 없음 | Froala Editor |
| 파일 업로드 | ImageProcessor 서비스 | Active Storage |
| 페이지네이션 | 없음 | Kaminari |
| 폰트 | Inter | Salesforce Sans, Lato |

**참고 자료**:

- [Tailwind CSS 공식 문서](https://tailwindcss.com/docs)
- [Froala Editor 공식 문서](https://froala.com/wysiwyg-editor/docs/)
- [Froala Rails Gem (wysiwyg-rails)](https://github.com/froala/wysiwyg-rails)
- [Active Storage 가이드](https://guides.rubyonrails.org/active_storage_overview.html)
- [Kaminari GitHub](https://github.com/kaminari/kaminari)

### ✅ 체크사항

- [x] 비슷한 기능 요청이 없는지 확인했습니다.
- [x] 이 변경이 프로젝트의 새로운 방향성에 맞습니다.
- [x] BREAKING CHANGE임을 인지하고 있습니다.
- [x] 기존 데이터 백업이 필요한 경우 대비했습니다.
- [x] 테스트가 모두 통과하는지 확인할 예정입니다.
