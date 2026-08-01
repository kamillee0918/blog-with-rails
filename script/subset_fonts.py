#!/usr/bin/env python3
"""app/assets/fonts 의 Lato woff2 를 라틴 범위로 서브셋한다.

배포된 Lato 원본은 Cyrillic·Greek·IPA 까지 포함해 파일당 200KB 안팎이었다.
이 블로그는 한글과 라틴 문자만 쓰고 한글은 어차피 시스템 폰트로 폴백되므로,
쓰지 않는 문자를 덜어내 파일당 40KB대로 줄인다.

  사용법:  pip install fonttools brotli
           python script/subset_fonts.py [--check]

  --check  파일을 쓰지 않고 현재 폰트가 안전 조건을 만족하는지만 검사한다.

안전 조건: 사이트에 실제로 등장하면서 원본 폰트가 지원하던 코드포인트는
서브셋 후에도 전부 남아야 한다. 이미 서브셋된 폰트를 다시 돌려도 조건은
그대로 유지되므로 반복 실행해도 안전하다.

문자 범위를 넓혀야 하면(예: 베트남어 표기 추가) RANGES 에 블록을 더하고
다시 실행한다. 원본 폰트는 git 이력에 남아 있다.
"""
from __future__ import annotations

import glob
import html
import os
import re
import sqlite3
import sys

try:
    from fontTools import subset
    from fontTools.ttLib import TTFont
except ImportError:
    sys.exit("fonttools 가 필요하다:  pip install fonttools brotli")

# Windows 기본 콘솔(cp949)에서 한글 출력이 깨지지 않도록 한다.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_GLOB = os.path.join(ROOT, "app", "assets", "fonts", "lato-*.woff2")

# Google Fonts 의 latin 범위 + Latin Extended-A.
# 같은 사이트에서 쓰는 Salesforce-Sans 의 커버리지(cmap 422자)와 비슷한 수준이라
# 폴란드/체코/터키/헝가리 등의 이름 표기까지 문제없다.
# 화살표는 오류 페이지의 "← Go back to homepage" 에서 쓰므로 명시적으로 포함한다.
RANGES = (
    "U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,"
    "U+0304,U+0308,U+0329,U+2000-206F,U+2074,U+20AC,U+2122,"
    "U+2190-2193,U+2212,U+2215,U+FEFF,U+FFFD,"
    "U+0100-017F,U+2020,U+20A0-20AB,U+20AD-20C0"
)


def site_codepoints() -> set[int]:
    """사이트에 렌더링될 수 있는 문자를 넓게 수집한다."""
    chars: set[str] = set()

    sources = [
        os.path.join(ROOT, "app", "views", "**", "*.erb"),
        os.path.join(ROOT, "app", "assets", "stylesheets", "*.css"),
        os.path.join(ROOT, "app", "javascript", "**", "*.js"),
        os.path.join(ROOT, "config", "locales", "*.yml"),
    ]
    for pattern in sources:
        for path in glob.glob(pattern, recursive=True):
            with open(path, encoding="utf-8", errors="replace") as fh:
                chars.update(fh.read())

    db = os.path.join(ROOT, "storage", "development.sqlite3")
    if os.path.exists(db):
        con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
        tables = {r[0] for r in con.execute("select name from sqlite_master where type='table'")}
        if "posts" in tables:
            for row in con.execute("select title, summary, category, author from posts"):
                chars.update("".join(value or "" for value in row))
        if "action_text_rich_texts" in tables:
            for (body,) in con.execute("select body from action_text_rich_texts"):
                chars.update(html.unescape(re.sub(r"<[^>]+>", " ", body or "")))
        if "tags" in tables:
            for (name,) in con.execute("select name from tags"):
                chars.update(name or "")
        con.close()

    return {ord(c) for c in chars}


def main() -> int:
    check_only = "--check" in sys.argv
    site_cps = site_codepoints()
    print(f"사이트 텍스트 고유 코드포인트: {len(site_cps)}개\n")

    before_total = after_total = 0
    failures = []

    for path in sorted(glob.glob(FONT_GLOB)):
        name = os.path.basename(path)
        before = os.path.getsize(path)

        with TTFont(path, lazy=True) as font:
            original_cmap = set(font.getBestCmap())
        must_keep = original_cmap & site_cps

        if check_only:
            missing = must_keep - original_cmap
            print(f"{name:<28} {before / 1024:6.0f} KB  cmap={len(original_cmap)}  "
                  f"필수문자 {len(must_keep)}개 {'OK' if not missing else 'MISSING'}")
            before_total += before
            after_total += before
            continue

        tmp = path + ".subset"
        subset.main([
            path,
            f"--unicodes={RANGES}",
            "--flavor=woff2",
            f"--output-file={tmp}",
            "--drop-tables+=DSIG",
            "--name-IDs=*",
        ])

        with TTFont(tmp, lazy=True) as font:
            new_cmap = set(font.getBestCmap())
        missing = must_keep - new_cmap
        if missing:
            failures.append((name, sorted(missing)))
            os.remove(tmp)
            continue

        os.replace(tmp, path)
        after = os.path.getsize(path)
        before_total += before
        after_total += after
        print(f"{name:<28} {before / 1024:6.0f} KB -> {after / 1024:5.0f} KB  "
              f"({100 * (1 - after / before):4.1f}% 감소)  cmap {len(original_cmap)}->{len(new_cmap)}  OK")

    if failures:
        print("\n중단 — 사이트에서 쓰는 문자가 빠진다. RANGES 에 해당 블록을 추가하라:")
        for name, missing in failures:
            sample = ", ".join(f"U+{cp:04X}({chr(cp)!r})" for cp in missing[:20])
            print(f"  {name}: {len(missing)}개 — {sample}")
        return 1

    if not check_only:
        print(f"\n합계 {before_total / 1024:.0f} KB -> {after_total / 1024:.0f} KB "
              f"({(before_total - after_total) / 1024:.0f} KB 절감)")
    print("검증 통과: 사이트에서 쓰이며 원본이 지원하던 문자가 모두 유지됨")
    return 0


if __name__ == "__main__":
    sys.exit(main())
