# blog-with-rails 리포지토리 PR Guide
아래와 같은 양식으로 PR 요청 시 작성되어야 한다.

- 제목: `타입: 요약` — **번호 접미사는 붙이지 않는다.**

```
feat: 데이터베이스 쿼리 성능 최적화를 위한 복합 인덱스 추가
```

> 아래 예시는 PR #13 에서 가져왔다. 이슈 번호는 제목이 아니라 본문의 `## 📚 관련 Issue` 에 적는다.

- 타입은 다섯 가지에 `perf` 를 더해 쓴다. 이슈 제목의 대괄호 어휘와 짝을 이룬다.

| PR 제목 | 이슈 제목 | 라벨 |
|---|---|---|
| `feat:` | `[Feature]:` | ✨ Feature |
| `fix:` | `[Fix]:` | 🐞 BugFix (긴급이면 🚨 HotFix 추가) |
| `refactor:` | `[Refactor]:` | 🔨 Refactor |
| `chore:` | `[Chore]:` | 🔧 Chore |
| `lighthouse:` | `[Lighthouse]:` | 🔦 Lighthouse |
| `perf:` | `[Enhancement]:` | 🔆 Enhancement |

라벨은 성격에 따라 **복수로** 붙인다(예: 이슈 #83 은 `🎨 Html&css` + `🔆 Enhancement` + `🔦 Lighthouse`). 제목 접두는 주된 성격 하나만 고른다. `dependencies` / `ruby` / `github_actions` 는 dependabot 전용이므로 사람이 붙이지 않는다.

- 본문 내용
```
## 🎯 목적
데이터베이스 쿼리 성능 최적화를 위한 복합 인덱스 추가

## 📝 변경사항
- Newsletter 구독자 조회 쿼리 최적화 (40-60% 향상)
  - `users` 테이블에 `(verified, enable_newsletter_notifications, deleted_at)` 복합 인덱스 추가
- Featured Posts 조회 쿼리 최적화 (20-30% 향상)
  - `posts` 테이블에 `(published_at, featured)` 복합 인덱스 추가

## 🧪 테스트
- [x] 마이그레이션 실행 확인
- [x] 쿼리 성능 검증 (`EXPLAIN QUERY PLAN`)
- [x] 기존 테스트 통과 확인

## 📚 관련 Issue
Resolves #12

## ✅ 체크리스트
- [x] SQLite 최적화에 집중
- [x] 복합 인덱스 Left-prefix rule 준수
- [x] 마이그레이션 파일 작성 완료
```

## 이슈가 선행되지 않은 경우

`## 📚 관련 Issue` 는 비우지 말고 사유를 적는다. 운영 중 발견해 즉시 고친 건은 이슈를 소급 생성하지 않는다 — 이슈의 생성 시각이 PR 보다 늦어져 "계획하고 작업했다"는 기록이 사실과 달라지기 때문이다.

```markdown
## 📚 관련 Issue
해당 없음 — 운영 중 발견해 즉시 수정
```

이때 성격은 라벨로 표시한다(장애 대응이면 `🚨 HotFix`).