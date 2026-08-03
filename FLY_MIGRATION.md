# 홈서버 → Fly.io 이전 절차서

- **작성일**: 2026-08-02
- **대상**: `kamillee0918.blog`
- **배경**: 홈서버 하드웨어/가상화 의존 제거. 현재 사이트는 Cloudflare `error 1033`(Tunnel 끊김)으로 다운 상태.

## 사전 검증 결과 (완료)

| 항목 | 결과 |
|---|---|
| `rev/storage/master.key` | ✅ **유효** — `credentials.yml.enc` 복호화 성공 (`aes-128-gcm`, `secret_key_base` 확인) |
| 본문 이미지 서명 | ✅ 키가 동일하므로 27개 URL 그대로 유효. 재서명 불필요 |
| `rev/storage` 백업 | ⚠️ **부분적** — 2026년 3월 이전 개발 환경 스냅샷 |
| 앱 설정 | ✅ `assume_ssl`, `/up` 헬스체크, Host 검증 제외 모두 이미 구성됨. 코드 수정 불필요 |

**복원 가능 범위**

| 대상 | 총 | 복원 | 재업로드 필요 |
|---|---:|---:|---:|
| 표지 이미지 | 28 | 11 | 17건 (고유 6장) |
| 본문 임베드 이미지 | 27 | 21 | 6건 (고유 6장) |
| variant | 377 | 자동 재생성 | — |

재업로드 대상은 **blob 33건이지만 고유 파일로는 14장**입니다. 같은 썸네일이 여러 글에 재사용되기 때문입니다.

| 파일 | 크기 | 영향 |
|---|---:|---|
| `shogi_re_thumbnail.png` | 1,320KB | 표지 7건 — post 3, 4, 15, 16, 17, 18, 19 |
| `atcoder.png` | 1,934KB | 표지 5건 — post 28~32 (PAST 시리즈 전체) |
| `2025_final.png` | 1,194KB | 표지 1건 — post 20 |
| `ai_thumbnail.png` | 8,673KB | 표지 2건 — post 11, 12 |
| `vton_thumbnail.png` | 1,572KB | 표지 1건 — post 27 |
| `sorry.png` | 1,036KB | 표지 1건 — post 26 |
| `blobid*.png` 8장 | 20KB~1.9MB | 본문 임베드 |

> 재업로드하는 김에 **WebP 변환 + 용량 축소**를 함께 하시길 권합니다. 현재 표지가 전부 PNG 평균 1.7MB이고, `ai_thumbnail.png`는 8.7MB입니다.

---

## 1. Fly.io 초기 설정

```bash
fly auth login
fly apps create kamillee0918-blog

# 볼륨: Active Storage blob + Solid Cache/Queue/Cable SQLite 가 모두 들어간다.
# 현재 사용량 144MB, 여유를 둬 3GB.
fly volumes create blog_storage --size 3 --region nrt
```

`fly.toml`은 이미 저장소에 있습니다. 확인할 값:

- `primary_region = "nrt"` — 도쿄. `fly platform regions`로 현재 목록 확인
- `HTTP_PORT = "8080"` / `internal_port = 8080` — Thruster 기본값은 80이지만 컨테이너가 비root(UID 1000)로 실행되므로 특권 포트를 피한다. **두 값은 반드시 일치해야 한다**
- `min_machines_running = 1` — 콜드 스타트 없이 상시 가동. 비용을 줄이려면 `auto_stop_machines = "suspend"` + `min_machines_running = 0`

## 2. 시크릿 주입

```bash
fly secrets set \
  RAILS_MASTER_KEY="$(cat rev/storage/master.key)" \
  SUPABASE_DB_PASSWORD="<Supabase DB 비밀번호>" \
  TINYMCE_API_KEY="<TinyMCE 키>" \
  ADMIN_EMAIL="parousia0918@gmail.com" \
  ADMIN_PASSWORD="<관리자 비밀번호>"
```

`SUPABASE_DB_HOST` / `PORT` / `USER`는 비밀이 아니라 `fly.toml`의 `[env]`에 있습니다.

> `ADMIN_*`는 `db/seeds.rb`가 참조합니다. `admins` 테이블에 이미 계정이 있으므로 `db:prepare`만 도는 평시에는 필요 없지만, seed를 다시 돌릴 경우를 위해 넣어 둡니다.

## 3. 최초 배포

```bash
fly deploy
```

이 단계에서 일어나는 일:

1. `Dockerfile`로 이미지 빌드 (Ruby 3.4.5, libvips 포함)
2. 볼륨이 `/rails/storage`에 마운트됨
3. `bin/docker-entrypoint`가 `bin/rails db:prepare` 실행 → **미배포 마이그레이션 2건이 Supabase에 자동 적용됨**
   - `20260731120000_add_published_at_index_to_posts`
   - `20260801060000_add_word_count_to_posts` (전체 글 순회하며 `word_count` 백필)
4. Thruster가 8080에서 기동, `/up` 헬스체크 통과

**첫 기동은 반드시 로그를 보면서 하십시오.** `db:prepare`가 실패하면 `docker-entrypoint`의 `set -e` 때문에 컨테이너가 아예 뜨지 않습니다.

```bash
fly logs
```

## 4. Active Storage 파일 복원

```bash
# 백업 → Active Storage 규약(확장자 없는 key, xx/yy/key)으로 재구성
ruby script/restore_storage.rb          # 결과: tmp/storage_restored/
tar czf storage_restore.tar.gz -C tmp/storage_restored .

# Fly 볼륨으로 업로드 후 전개
fly ssh sftp shell
  put storage_restore.tar.gz /rails/storage/restore.tar.gz
  exit
fly ssh console -C "sh -c 'cd /rails/storage && tar xzf restore.tar.gz && rm restore.tar.gz'"
```

### 4-1. 깨진 variant 레코드 정리 (필수)

**이 단계를 빠뜨리면 이미지가 전부 404가 됩니다.**

Rails는 `ActiveStorage::VariantRecord` 행이 DB에 있으면 그 variant를 "이미 생성됨"으로 판단해 **재생성하지 않고** 해당 파일을 스트리밍하려 합니다. Supabase에는 variant 레코드 377건이 남아 있는데 복원된 파일은 160개뿐이라, 나머지 217건이 `FileNotFoundError` → 404가 됩니다.

파일이 없는 variant 레코드를 지워야 다음 요청 때 원본으로부터 재생성됩니다.

**반드시 한 줄로 실행하십시오.** `-C` 값에 큰따옴표나 줄바꿈이 들어가면 flyctl이 문자열을 도중에 끊고 뒤쪽 단어를 호스트명으로 해석합니다 (`host was not found in DNS`).

```bash
fly ssh console -C "bin/rails runner 'n=0; ActiveStorage::VariantRecord.includes(image_attachment: :blob).find_each { |v| b=v.image_blob; next if b && ActiveStorage::Blob.service.exist?(b.key); v.image_attachment&.purge; v.destroy; n+=1 }; puts n'"
```

인용 문제가 계속 생기면 대화형 콘솔에서 붙여넣는 편이 확실합니다.

```bash
fly ssh console --pty -C "bin/rails console"
```
```ruby
n = 0
ActiveStorage::VariantRecord.includes(image_attachment: :blob).find_each do |v|
  b = v.image_blob
  next if b && ActiveStorage::Blob.service.exist?(b.key)
  v.image_attachment&.purge
  v.destroy
  n += 1
end
n   # => 삭제된 variant 레코드 수 (217 예상)
```

원본이 남아 있는 64건은 이후 첫 요청에서 libvips가 variant를 다시 만들어 정상 표시됩니다. 원본이 없는 33건(고유 14장)은 §7의 재업로드가 끝나야 복구됩니다.

### 4-2. 이미지 분석 잡

`width`/`height` 메타데이터를 채웁니다. 현재 표지 28장 전부 `analyzed=0`이라 전 페이지에서 레이아웃 시프트(CLS)가 발생합니다.

**재업로드가 끝난 뒤에 실행하십시오** — 파일이 없는 블롭은 분석에 실패합니다.

```bash
fly ssh console -C "bin/rails runner 'ActiveStorage::Blob.find_each { |b| b.analyze_later if !b.analyzed? && ActiveStorage::Blob.service.exist?(b.key) }'"
```

`Blob#analyzed?`가 `metadata[:analyzed]`를 그대로 확인하므로, SQL `LIKE`에 큰따옴표를 섞을 필요가 없습니다. 앞서 실행하신 `where(metadata: nil)` 조건은 `metadata`가 빈 해시인 경우를 놓칩니다.

## 5. 도메인 전환

**순서가 중요합니다.** Cloudflare 프록시가 켜진 상태에서는 Fly의 인증서 발급(ACME HTTP-01)이 실패할 수 있습니다.

1. Cloudflare DNS에서 `kamillee0918.blog` 레코드를 **DNS only(회색 구름)** 로 전환하고 Fly를 가리키게 변경
   ```bash
   fly ips list          # 할당된 IPv4/IPv6 확인
   ```
2. 인증서 발급
   ```bash
   fly certs add kamillee0918.blog
   fly certs show kamillee0918.blog     # Verified 될 때까지 대기
   ```
3. Cloudflare 프록시를 **다시 켜고(주황 구름)**, SSL/TLS 모드를 **Full (strict)** 로 설정
4. 기존 Cloudflare Tunnel 삭제
5. `www` 레코드 추가 — 현재 `www.kamillee0918.blog`는 NXDOMAIN인데 `ALLOWED_HOSTS`에는 등록돼 있습니다

> **Cloudflare 프록시는 반드시 유지하십시오.** `config/initializers/cloudflare.rb`가 Cloudflare IP 대역을 신뢰 프록시로 등록해 실제 클라이언트 IP를 얻고, 로그인 브루트포스 차단이 그 IP에 의존합니다. 프록시를 끄면 모든 요청이 같은 IP로 보여 차단 로직이 오작동합니다.

## 6. 배포 후 검증

```bash
curl -I https://kamillee0918.blog/                    # 200 기대
curl -o /dev/null -w "%{http_code}\n" https://kamillee0918.blog/up
```

체크리스트:

- [ ] 목록 페이지에 `N min read` 표시 — `word_count` 마이그레이션 적용 확인
- [ ] 표지 이미지 렌더링 (복원 11건 + 재업로드분)
- [ ] 본문 이미지 렌더링 — 서명 유효성 확인 (`master.key`가 맞으면 21개 정상)
- [ ] 관리자 로그인 — 세션 유지 여부
- [ ] 외부 uptime 모니터 등록 (UptimeRobot 등)

### ⚠️ 확인된 문제: `remote_ip`가 Fly 프록시 IP로 잡힘

배포 로그에서 실제로 관측된 내용입니다.

```
Started GET "/" for 66.241.124.114        ← Rails 가 인식한 클라이언트 IP (Fly 공유 IPv4)
"remote_addr":"39.124.186.141, 66.241.124.114"   ← 실제 XFF 체인 (앞이 진짜 클라이언트)
```

`config/initializers/cloudflare.rb`는 Cloudflare 대역만 신뢰 프록시로 등록합니다. Fly의 프록시 IP는 그 목록에 없어 필터링되지 않고, `ActionDispatch::RemoteIp`가 이를 클라이언트 IP로 판정합니다.

**영향**: 로그인 브루트포스 차단이 IP별로 동작하지 않습니다. 모든 요청이 같은 IP로 보이므로 누군가의 실패 시도가 전체를 잠글 수 있습니다.

**대응**: Cloudflare를 앞에 두면 체인이 `클라이언트, Cloudflare, Fly`가 되므로, Cloudflare가 넣어 주는 `CF-Connecting-IP`를 신뢰하는 편이 IP 대역 목록을 관리하는 것보다 안정적입니다. 도메인 전환(§5) 완료 후 실제 체인을 다시 확인하고 초기화 파일을 조정해야 합니다.

확인 방법:

```bash
fly logs | grep 'Started GET'      # 앞의 IP 가 본인 공인 IP 와 일치하는지
```

## 7. 이전 후 남는 작업

`BLOG_CONTENT_REVIEW.md`의 P1 항목 중 이번 이전과 맞물리는 것들:

- [ ] 재업로드 대상 고유 이미지 14장 확보 및 WebP 변환
- [ ] 끊어진 내부 링크 8개 수정 (Gumbel AlphaZero 시리즈 `gumbel-alphazero-N` → `gumbel-alphazero-part-N`)
- [ ] `config/database.yml:34-37`의 죽은 폴백 제거 — `tqcmbdphezkdyqvjpkvy` / `ap-southeast-2`는 더 이상 존재하지 않는 값
- [ ] `config/environments/production.rb:98`의 `cfargotunnel.com` 허용 규칙 제거 (Tunnel 폐기 후 불필요)
- [ ] `config/deploy.yml` 정리 또는 삭제 — Kamal은 쓰지 않게 됨
- [ ] Supabase 정기 백업 구성

## 롤백

Fly는 릴리스 단위 롤백을 지원합니다.

```bash
fly releases
fly deploy --image <이전 릴리스 이미지>
```

DNS를 이미 전환한 뒤라면 Cloudflare에서 레코드를 되돌리는 편이 빠릅니다. 다만 **홈서버는 이미 다운 상태이므로 실질적인 롤백 대상이 없습니다** — 이전 실패 시 복구 경로는 "Fly에서 다시 시도"뿐입니다.

## 비용 예상

| 항목 | 사양 | 월 비용(대략) |
|---|---|---|
| Machine | `shared-cpu-1x` / 1GB RAM / 상시 가동 | $5~6 |
| Volume | 3GB | $0.5 |
| **합계** | | **$6 안팎** |

데스크톱을 24시간 켜두는 전기료(유휴 60W 기준 월 40kWh 안팎)보다 저렴합니다. 정확한 요금은 Fly.io 요금 페이지에서 확인하십시오 — 조건이 자주 바뀝니다.
