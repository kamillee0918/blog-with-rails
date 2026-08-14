# blog-with-rails 리포지토리 Issue Guide
아래와 같은 양식으로 Issue 작성 시 작성되어야 한다.

- 제목: `[타입]: 요약` — **번호 접미사는 붙이지 않는다.**

```
[Feature]: TinyMCE 에디터 통합
```

> 아래 예시는 이슈 #63 에서 가져왔다.

- 대괄호 어휘는 여섯 가지다. PR 제목의 접두와 짝을 이룬다 — 대응표는 `PR_GUIDE.md` 참고.

```
[Feature]  [Fix]  [Refactor]  [Chore]  [Lighthouse]  [Enhancement]
```

라벨은 이와 별개로 성격에 따라 **복수로** 붙인다. 제목 접두는 주된 성격 하나만 고른다.

- 본문 내용
```
### 💡 기능 요약

관리자 글쓰기 경험을 개선하기 위해 TinyMCE 에디터를 도입하고, 드래그&드롭 이미지 업로드를 Active Storage 기반으로 지원합니다.
코드 블록은 Base64 인코딩으로 안전하게 저장/복원하며, Turbo Drive와의 호환성을 보장합니다.

### 🛠️ 구현 계획

### 1. TinyMCE 에디터 초기화 및 Turbo 호환

- **환경 변수 기반 API Key**: `TINYMCE_API_KEY`를 환경 변수로 관리
- **레이아웃 로드**: `application.html.erb`에서 TinyMCE 스크립트 로드 및 `<meta name="tinymce-api-key">` 제공
- **Turbo 호환 초기화**: `init.js`에서 `turbo:load` 시점에 에디터 초기화(중복 초기화 방지)
- **코드 블록 처리**: Base64 인코딩/디코딩으로 코드 블록 내용 안전하게 보존

### 2. 이미지 업로드 (Active Storage)

- **업로드 엔드포인트**: `POST /uploads/image`
- **응답 포맷**: TinyMCE 요구 포맷 `{ "location": "..." }` 준수
- **검증**: 파일 타입/크기 제한 (`MAX_FILE_SIZE = 10.megabytes`)
- **권한**: 관리자만 업로드 가능
- **srcset 생성**: 반응형 이미지를 위한 7단계 해상도 자동 생성

### 3. 보안 강화

- **extended_valid_elements 제한**: `script[*]` 제거, `template[id]`만 허용
- **turbo-stream 지원**: `turbo-stream[action|target]` 허용

### 🔥 우선순위

🔴 높음 - 관리자 콘텐츠 작성 UX

### 📋 구현 체크리스트

### TinyMCE
- [x] `TINYMCE_API_KEY` 환경 변수 기반 로드 (`application.html.erb`)
- [x] Turbo 호환 초기화 및 중복 방지 (`app/javascript/init.js`)
- [x] 코드 블록 Base64 인코딩/디코딩 처리
- [x] `script[*]` 제거로 XSS 방어

### 뷰 업데이트
- [x] `show.html.erb` 레이아웃 개선
- [x] `show_all.html.erb` 목록 뷰 개선

### 📝 추가 정보

**주요 변경 파일**:

```
수정:
├── app/javascript/init.js
├── app/views/layouts/application.html.erb
├── app/views/posts/show.html.erb
└── app/views/posts/show_all.html.erb
```

### ✅ 체크사항

- [x] 관리자 글 작성/수정 화면에서 에디터 정상 로드
- [x] Turbo 페이지 이동 후에도 중복 초기화 없음
- [x] 드래그&드롭 이미지 업로드 정상 동작
- [x] 코드 블록 저장/복원 정상 동작
- [x] `bin/check-code` 및 테스트 실행
```