# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.1 blog application (Ruby 3.4.5). Hotwire (Turbo + Stimulus) with importmap — no Node/bundler; custom CSS (no Tailwind). Action Text + TinyMCE for authoring, Active Storage + libvips for images, Kaminari for pagination. Deployed to Fly.io as a Docker container behind Cloudflare; production DB is Supabase PostgreSQL.

## Commands

```bash
bin/setup                # install deps, prepare DB
bin/dev                  # dev server via foreman (http://localhost:3000)
bin/rails db:seed        # admin account + sample posts

# Tests (minitest, parallel workers, SimpleCov branch coverage → coverage/)
bin/rails test                                    # unit + integration
bin/rails test:system                             # Capybara/Selenium — needs Chrome
bin/rails test test/models/post_test.rb           # single file
bin/rails test test/models/post_test.rb:42        # single test by line

# Quality gates
bin/check-code           # pre-push gate: Brakeman → RuboCop → all tests
bin/ci                   # full local CI (adds bundler-audit, importmap audit, seed replant)
bin/rails content:check  # content audit (see below) — SEVERITY=error to skip warnings
bin/rubocop -a           # style (rubocop-rails-omakase) with autocorrect
bin/brakeman --no-pager  # security static analysis (suppressions: config/brakeman.ignore)
```

Environment notes:

- Host is Windows; `bin/*` are POSIX shell scripts — run them from Git Bash. `.gitattributes` forces LF on `bin/*` (CRLF breaks shebangs in Docker builds).
- Booting the app requires the libvips system library (ruby-vips loads it via FFI). CI and the Dockerfile install it explicitly.
- `.env` (dotenv-rails) supplies dev env vars like `TINYMCE_API_KEY`. Production requires `ADMIN_EMAIL`/`ADMIN_PASSWORD` — `db/seeds.rb` raises without them to prevent a default-credential admin.

## Issue and PR conventions

**`ISSUE_GUIDE.md` and `PR_GUIDE.md` are mandatory templates, not suggestions.** Follow them for every issue and pull request. They were skipped for #135–#150 and those had to be rewritten afterwards.

Titles carry a type and **no number suffix** — the `- #13` in the guides' examples cites where the example came from, it is not part of the format. Verified: zero of 26 issues and zero of 34 PRs carry such a suffix.

| PR title | Issue title | Label |
|---|---|---|
| `feat:` | `[Feature]:` | ✨ Feature |
| `fix:` | `[Fix]:` | 🐞 BugFix (add 🚨 HotFix when urgent) |
| `refactor:` | `[Refactor]:` | 🔨 Refactor |
| `chore:` | `[Chore]:` | 🔧 Chore |
| `lighthouse:` | `[Lighthouse]:` | 🔦 Lighthouse |
| `perf:` | `[Enhancement]:` | 🔆 Enhancement |

The title prefix names the single dominant type; labels are the multi-axis dimension and several apply at once (issue #83 carries 🎨 Html&css + 🔆 Enhancement + 🔦 Lighthouse). `dependencies` / `ruby` / `github_actions` belong to dependabot — never attach them by hand, and leave dependabot's own PRs alone: it regenerates their bodies, so edits are lost.

`## 📚 관련 Issue` is never left blank. When an issue came first, `Resolves #NN`. When something was found in production and fixed on the spot, say so — do **not** backfill an issue afterwards, because its timestamp would land after the PR and misrepresent the work as planned:

```markdown
## 📚 관련 Issue
해당 없음 — 운영 중 발견해 즉시 수정
```

## Architecture

### Database topology

- development/test: SQLite (`storage/*.sqlite3`). Production primary: Supabase PostgreSQL via transaction pooler (`prepared_statements: false` is required for pooler compatibility).
- Solid Cache/Queue/Cable always use separate local SQLite databases, even in production (`SOLID_QUEUE_IN_PUMA=true` runs jobs inside Puma).

### Admin auth (no Devise)

Single `Admin` model (`has_secure_password`); session-based login in `SessionsController` with `reset_session` on login. `ApplicationController#admin_signed_in?` enforces a 12-hour session timeout. There is no admin namespace — admin capability is `authenticate_admin!` on write actions of `PostsController` and `UploadsController`.

Login throttling counts **failed** attempts per IP in `Rails.cache` (Solid Cache in production) and clears the counter on success. Two things to preserve if you touch it: the count must not live in the session, because a client that discards cookies would reset it; and Rails 8's `rate_limit` is deliberately unused, because it counts every request including successes and offers no reset hook, which locks the sole owner out of their own site. `remote_ip` is the real client IP thanks to the trusted-proxy ranges in `config/initializers/cloudflare.rb` — which must list **every** hop, Cloudflare *and* Fly, since `ActionDispatch::RemoteIp` takes the last address it does not recognise as a proxy. Miss one and every request looks like it came from that hop, collapsing the per-IP counter into a single global one that a stranger's failures can use to lock the owner out.

### Post visibility and caching

`PostsController#post_scope` is the pivot: admins see `Post.all`, the public sees `Post.published` (`published_at <= now`, so future dates are scheduled posts). Always go through this scope (and `Post.find_by_slug_or_id!`, which preserves the current scope) — bypassing it leaks unpublished posts. HTTP caching splits on the same check: public responses use `fresh_when`/`stale?` ETags, admin responses get no-store headers.

Two caching details are load-bearing and easy to undo by accident:

- `ApplicationController::CONDITIONAL_GET_CACHE_CONTROL` spells out `max-age=0, private, must-revalidate` by hand. Rails only fills those in from `handle_conditional_get!` when `Cache-Control` is still unset at commit, and the `after_action` that appends `no-transform` runs earlier — so touching the header at all (raw or via `cache_control[:extras]`) suppresses the default and drops public HTML into RFC 9111 heuristic freshness.
- `#index` builds its ETag from `@posts.cache_version` plus the params that select the response, **not** from the relation. `Relation#cache_key` digests `to_sql`, and `Post.published` is a string condition, so `Time.current` is inlined down to the microsecond and the ETag would change on every request.

Changing only a post's tags does not dirty the record, so `Post#tag_list=` touches it — otherwise the ETag never moves and readers keep the old badges.

Posts are addressed by slug or numeric id (`to_param`): English titles auto-generate a slug via `parameterize`; Korean titles produce an empty slug and fall back to id.

### Code-block Base64 pipeline (most non-obvious subsystem)

Action Text's sanitizer (Nokogiri) corrupts HTML entities inside `<pre><code>`. The workaround spans four files and both directions must stay in sync:

1. **Save**: `PostsController#encode_code_blocks` Base64-encodes code-block innards (`BASE64:...`) before Action Text sees them.
2. **Render**: `Post#rendered_content` decodes and returns `html_safe` HTML; views must use `rendered_content`, not `content`, for display.
3. **Edit**: `app/javascript/init.js` decodes for TinyMCE reload (and re-encodes legacy raw HTML).
4. Legacy `⟦ERB_*⟧` placeholder posts are still decoded as a fallback.

`config/initializers/action_text.rb` extends the sanitizer allow-list (tables, svg, `data-turbo`). The decode regex is looser than the encode one, so a block that was never encoded can still match it; a failed `strict_decode64` leaves the block untouched instead of raising, which used to 500 the post for every visitor.

### Image serving (two paths)

1. **Cover images**: Active Storage `cover_image` with named WebP variants (`:thumbnail`…`:hero`) defined on `Post`; rendered through `ImageHelper` (`optimized_image_tag`, `responsive_image_tag`). Only the LCP image should get `fetchpriority: high`/`lazy: false`.
2. **In-post images**: TinyMCE uploads to `UploadsController` (type/size validation), which returns a JSON `srcset` of Active Storage variant URLs.

`config.active_storage.resolve_model_to_route = :rails_storage_proxy` in `config/application.rb` is what makes either path CDN-cacheable — the default redirect mode emits `max-age=300, private` behind a 302, which Cloudflare cannot cache. Build URLs with `url_for`/`polymorphic_path` so they follow that setting; `rails_blob_url` and `rails_blob_representation_url` are pinned to the redirect routes and silently ignore it.

`ImageHelper#intrinsic_dimensions` derives `width`/`height` from the blob's analyzed size rather than hardcoding them. Those attributes drive an `aspect-ratio` that keeps governing the box after load, so a wrong pair stretches the image wherever no `object-fit` hides it. When the analysis job has not run yet the attributes are omitted rather than guessed.

A third path used to exist — `ThumbnailsController` resizing `app/assets/images/thumbnail/` on demand — and was removed: no view ever linked to it, and an unvalidated `width` let anyone evict the whole cache.

Reusing one cover across posts is a supported operation, not a hack: `bin/rails cover:reuse SRC=<slug|id> DST=<slug|id>` (`CoverBlobs`, `FORCE=1` to replace an existing cover) attaches the source post's blob to another post, so the file, its analysis and the already-built WebP variants are all reused and nothing new lands on the volume — re-uploading the same image costs the original *and* a fresh set of variants. It goes through `find_by_slug_or_id` rather than `published`, because the target is usually a post that has not gone out yet. Sharing is safe because of the foreign key on `active_storage_attachments`: `ActiveStorage::Blob#purge` rescues `InvalidForeignKey`, so a blob another post still references survives both a `purge` and a cover replacement. `test/models/cover_blobs_test.rb` pins that invariant — drop the FK and that test fails before the covers do.

`ActiveStorage::Blob.unattached` is **not** a garbage signal here. `UploadsController#image` creates in-post image blobs with `create_and_upload!` and never attaches them — only their URL goes into the body — so every live in-post image (27 of them at the time of writing) looks unattached. A cleanup task must first resolve the signed ids in `post.content.body_before_type_cast` and spare those; one written against `unattached` alone deletes the blog's illustrations.

### Frontend

Importmap ESM only. Stimulus controllers live in `app/javascript/controllers/`; `app/javascript/init.js` is a separate non-Stimulus module handling TinyMCE, PrismJS, and MathJax initialization with Turbo lifecycle events — third-party widget integration usually belongs there. Trix and Action Text's JS are deliberately not pinned: the editor is a TinyMCE-backed `text_area`, so they were dead weight that importmap still preloaded.

Prism, Mermaid and MathJax are loaded per page, not globally. A view declares what it needs via `ApplicationHelper#require_content_libraries` — `posts#show` derives it from the body with `content_libraries_for`, the editor form declares `:prism` because TinyMCE's codesample plugin reads the global `Prism` — and the layout gates each script block on `content_library?`. Because the gated scripts only exist on pages that need them, a Turbo Drive visit would arrive before they execute; every post link therefore carries `data: { turbo: false }`.

Fonts are subset to the Latin ranges the site uses. `script/subset_fonts.py` reproduces it and enforces the safety property that makes it reviewable: every codepoint appearing in views, CSS, JS, locales or the posts table that the original font supported must survive.

### Content auditing

`ContentAudit` (`app/models/content_audit.rb`, exposed as `bin/rails content:check`) checks what the code gates cannot: broken internal links, missing/placeholder `alt`, short summaries, untagged posts, unanalysed or badly sized covers, and in-post images still on the `redirect` route. It is **data**, not code — running it against the dev database says nothing about the live site, so point it at production (`fly ssh console -C "bin/rails content:check"`). Errors set a non-zero exit; warnings do not, because they are judgement calls.

Three traps it deliberately avoids, all of which produced false positives or noise during the audits that motivated it:

- The malformed-link check strips the query string before looking for whitespace. `+` means space in a query but is a literal character in a path, so decoding the whole URL flags `?q=build+tools` as broken.
- A `/posts/` path only counts as internal when the link is relative or its host matches `APP_HOST`; other sites have `/posts/` too.
- The cover check measures **width, not bytes** (`COVER_MIN_WIDTH`/`COVER_MAX_WIDTH`). Every view renders covers through `ImageHelper`, so the original is never served and its file size costs the reader nothing — a 500KB byte rule flagged all 28 covers and taught the reader to ignore the check. What does matter is the two ends of the srcset: wider than the largest entry (1920) is decoded and thrown away on every variant build, and narrower than the hero's display width (1024) renders soft, because `resize_to_limit` will not upscale. Dimensions are only known once the blob is analysed, so an unanalysed cover skips the size check rather than guessing.

### Security configuration

- CSP in `config/initializers/content_security_policy.rb` is **report-only** (`unsafe_inline`/`unsafe_eval` currently required by TinyMCE/GA/MathJax).
- Production-only headers in `config/initializers/security_headers.rb`; Cloudflare **and** Fly ingress addresses as trusted proxies in `config/initializers/cloudflare.rb` (real client IP for the brute-force logic). Fly's shared IPv4 can be reassigned — override with `FLY_INGRESS_IPS` rather than editing the file when `fly ips list` changes.
- Suppression files: `config/brakeman.ignore` (currently empty), `config/bundler-audit.yml` — check these before "fixing" a scanner finding.

### Other conventions

- Error pages are dynamic: `config.exceptions_app = routes` → `ErrorsController` (`/404`, `/422`, `/500`).
- `posts#index` conditionally renders the `show_all` template (when `page` or `category` params are present); `search`/`tag`/`archive` also render `show_all`. Listing pages must use `listing_scope` (eager-loads tags and cover image) to avoid N+1.
- `Post#read_time` reads the denormalized `posts.word_count`, filled by a `before_save`. It must not touch `content` — parsing the Action Text body per card is exactly the cost the column removes, and it is why `listing_scope` no longer eager-loads rich text. Action Text bodies are not a `posts` column, so the record is not dirty when only the body changes; `before_save` still runs, which is what keeps the count in sync.
- Test fixtures include an admin (`admins(:one)`, password `"password"`); use the `sign_in_as_admin` helper in `test_helper.rb` for admin-only actions.
- Test env uses `:memory_store`, not `:null_store`, so login throttling is testable at all — and `test_helper.rb` clears the cache before each test, since every request comes from 127.0.0.1 and would otherwise inherit the previous test's attempts.
- Deployment: `fly deploy` with `fly.toml` (app `kamillee0918-blog`, region `nrt`). Non-secret config lives in `[env]`; `RAILS_MASTER_KEY`/`ADMIN_*`/`SUPABASE_DB_PASSWORD`/`TINYMCE_API_KEY` come from `fly secrets`. The `blog_storage` volume mounted at `/rails/storage` holds Active Storage blobs *and* the Solid Cache/Queue/Cable SQLite files — it is the app's only persistent state. `FLY_MIGRATION.md` is the runbook; Kamal was removed when the home server was retired.
- `bin/docker-entrypoint` runs `db:prepare` on boot, so a deploy applies pending migrations to Supabase automatically. `set -e` means a failed migration stops the container from booting at all.
- Host is Windows and `bin/*` are POSIX scripts: run tests as `PARALLEL_WORKERS=1 bin/rails test`. Windows has no `fork()`, so `parallelize` in `test_helper.rb` raises without that variable. CI runs on Linux and stays parallel.
