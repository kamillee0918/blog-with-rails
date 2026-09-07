// 코드 블록이 저장 왕복을 거쳐도 이스케이프가 자라지 않는지 확인한다.
//
//   node script/check_code_block_roundtrip.mjs
//
// 2026-09-07 에 발행글 7건 197곳에서 부등호가 글자로 보이는 손상을 발견했다.
// `&lt;` → `&amp;lt;` → `&amp;amp;lt;` … 저장할 때마다 한 겹씩 자라 있었고,
// 원인은 init.js 의 BeforeSetContent 핸들러가 「이미 엔티티인 콘텐츠」를
// 「raw HTML」로 보고 한 번 더 인코딩한 것이었다.
//
// 이 스크립트는 두 가지를 본다.
//   1. 왕복 모델이 멱등인가 — 깊이가 자라면 실패
//   2. init.js 가 그 인코딩을 되살리지 않았는가 — 소스를 직접 읽어 확인
//
// 의존성 없이 Node 만으로 돈다. 브라우저를 띄우지 않으므로 TinyMCE 자체가
// 아니라 「HTML 텍스트 노드의 파싱/직렬화」를 모델로 쓴다. 그 모델이 실제와
// 맞는다는 것은 손상된 프로덕션 바이트를 그대로 재현해서 확인했다.

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const initPath = join(root, "app", "javascript", "init.js");

// --- init.js 에서 그대로 옮긴 함수 (레거시 경로에서만 쓰인다) ---
function encodeRawHtmlForTinyMCE(raw) {
  return raw
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

// --- HTML 텍스트 노드의 파싱과 직렬화 (명세 그대로, 한 겹씩) ---
const parseTextNode = (s) =>
  s.replace(/&(amp|lt|gt);/g, (_, n) =>
    n === "amp" ? "&" : n === "lt" ? "<" : ">",
  );
const serializeTextNode = (s) =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

// --- 저장 왕복 한 바퀴 ---
// reencode 가 true 면 예전 동작(BeforeSetContent 에서 한 번 더 인코딩)이다.
function roundTrip(stored, { reencode = false } = {}) {
  const intoEditor = reencode ? encodeRawHtmlForTinyMCE(stored) : stored;
  return serializeTextNode(parseTextNode(intoEditor));
}

const SAMPLES = [
  "for (int i = 0; i &lt; N; i++) {",
  "if (a &amp;&amp; b) return;",
  "dp[0][1 &lt;&lt; 0] = 1;",
  "while (hi - lo &gt; 1) {",
  "List&lt;Integer&gt; chosen = new ArrayList&lt;&gt;();",
];

let failures = 0;
const fail = (msg) => {
  console.error(`  ✗ ${msg}`);
  failures += 1;
};
const pass = (msg) => console.log(`  ✓ ${msg}`);

console.log("1. 왕복이 멱등인가 (지금 동작)");
for (const sample of SAMPLES) {
  let value = sample;
  for (let i = 0; i < 5; i++) value = roundTrip(value);
  if (value === sample) {
    pass(`5회 왕복 후에도 그대로: ${sample}`);
  } else {
    fail(`5회 왕복에서 자랐다\n      전: ${sample}\n      후: ${value}`);
  }
}

console.log("\n2. 예전 동작은 실제로 자랐는가 (모델이 버그를 재현하는지)");
{
  let value = "i &lt; N";
  const ladder = [];
  for (let i = 0; i < 4; i++) {
    value = roundTrip(value, { reencode: true });
    ladder.push(value);
  }
  const expected = [
    "i &amp;lt; N",
    "i &amp;amp;lt; N",
    "i &amp;amp;amp;lt; N",
    "i &amp;amp;amp;amp;lt; N",
  ];
  try {
    assert.deepEqual(ladder, expected);
    pass("깊이 사다리를 재현한다 (프로덕션에서 관측된 2중~5중과 일치)");
  } catch {
    fail(`사다리가 다르다: ${JSON.stringify(ladder)}`);
  }
}

console.log("\n3. init.js 가 그 인코딩을 되살리지 않았는가");
{
  const source = readFileSync(initPath, "utf8");
  const handler = source.match(
    /editor\.on\("BeforeSetContent"[\s\S]*?\n      \}\);/,
  );

  if (!handler) {
    fail("BeforeSetContent 핸들러를 찾지 못했다 — 이 스크립트를 손봐야 한다");
  } else {
    const body = handler[0];
    const calls = [...body.matchAll(/encodeRawHtmlForTinyMCE\s*\(/g)];
    if (calls.length === 0) {
      pass("핸들러가 encodeRawHtmlForTinyMCE 를 직접 부르지 않는다");
    } else {
      fail(
        `핸들러가 encodeRawHtmlForTinyMCE 를 ${calls.length}번 부른다 — ` +
          "이미 엔티티인 콘텐츠를 한 번 더 인코딩하면 저장할 때마다 한 겹씩 자란다",
      );
    }

    if (/return match;/.test(body)) {
      pass("BASE64 도 ⟦ERB_ 도 아닌 블록은 손대지 않고 그대로 돌려준다");
    } else {
      fail("손대지 않고 돌려주는 갈래가 보이지 않는다");
    }
  }
}

console.log();
if (failures > 0) {
  console.error(`실패 ${failures}건 — 코드 블록이 다시 자랄 수 있다.`);
  process.exit(1);
}
console.log("통과 — 코드 블록 왕복이 멱등하다.");
