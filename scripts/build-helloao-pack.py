#!/usr/bin/env python3
"""Build a pinned, offline commentary pack from the HelloAO Free Use Bible API.

The app never talks to the HelloAO API at run time. This script fetches every chapter of
one commentary once, converts it to Thruline's `ResourceBook` JSON (the same shape the
Library already stores, searches and displays), and writes a manifest that pins what was
fetched: the sha256 of every raw chapter file as served, the sha256 of the finished pack,
and the upstream license record. The app downloads only the finished pack and refuses it
unless its sha256 matches the value compiled into the app.

    python3 scripts/build-helloao-pack.py adam-clarke
    python3 scripts/build-helloao-pack.py adam-clarke --check     # rebuild from cache, compare

Raw chapters are cached under work-content/helloao-pack/<id>/ (git-ignored). Re-running is
safe; existing chapter files are reused unless --force is given. HelloAO serves static JSON
from a CDN, so a small worker pool, a retry/backoff and an identifying User-Agent is the
polite way to fetch it.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "work-content/helloao-pack"
PACKS = ROOT / "resource-packs"
BASE = "https://bible.helloao.org"
USER_AGENT = "ThrulineBible/0.23 (offline Bible study; pack builder; https://github.com/fastermatt/thruline-bible)"
END_OF_CHAPTER = 999
CANON = ("GEN EXO LEV NUM DEU JOS JDG RUT 1SA 2SA 1KI 2KI 1CH 2CH EZR NEH EST JOB PSA PRO ECC SNG ISA JER LAM EZK DAN "
         "HOS JOL AMO OBA JON MIC NAM HAB ZEP HAG ZEC MAL MAT MRK LUK JHN ACT ROM 1CO 2CO GAL EPH PHP COL 1TH 2TH "
         "1TI 2TI TIT PHM HEB JAS 1PE 2PE 1JN 2JN 3JN JUD REV").split()
# HelloAO cuts some long introductions off mid-sentence at exactly this many characters
# (Ezra, Job, Song of Solomon and Isaiah in Adam Clarke). Say so in the text rather than
# let a reader take the cut for the author's ending.
UPSTREAM_CUT = 32767
CUT_NOTICE = "\n\n[The AO Lab digitization ends here; the rest of this introduction is not in the source text.]"

# Per-pack presentation. The license facts come from HelloAO's own record for the
# commentary (`licenseUrl`), which the builder checks; the wording here is Thruline's.
PACKS_META = {
    "adam-clarke": {
        "title": "Adam Clarke's Commentary on the Bible",
        "author": "Adam Clarke",
        "expected_license": "https://creativecommons.org/publicdomain/mark/1.0/",
        "rights": "Public domain (Public Domain Mark 1.0), as recorded by the HelloAO Free Use Bible API.",
        "work": "Clarke, Adam. The Holy Bible ... with a Commentary and Critical Notes (1810–1826).",
    },
}


def fetch(url: str, retries: int = 4) -> bytes:
    last: Exception | None = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=30) as resp:
                return resp.read()
        except (urllib.error.URLError, TimeoutError) as exc:
            last = exc
            time.sleep(0.5 * (2 ** attempt))
    raise RuntimeError(f"failed to fetch {url}: {last}")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def get_chapter(cid: str, book: str, chapter: int, force: bool) -> bytes:
    path = RAW / cid / book / f"{chapter}.json"
    if path.exists() and not force:
        return path.read_bytes()
    data = fetch(f"{BASE}/api/c/{cid}/{book}/{chapter}.json")
    json.loads(data)  # must be valid JSON before it is cached
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return data


def flatten(content) -> str:
    """HelloAO commentary content is a list of strings, usually; tolerate nested items."""
    parts: list[str] = []

    def walk(node) -> None:
        if isinstance(node, str):
            parts.append(node)
        elif isinstance(node, list):
            for item in node:
                walk(item)
        elif isinstance(node, dict):
            for key in ("text", "content"):
                if key in node:
                    walk(node[key])

    walk(content)
    text = "\n".join(p.strip() for p in parts if p and p.strip())
    return text.strip()


def anchor(book: str, c1: int, v1: int, c2: int, v2: int) -> dict:
    return {"book": book, "chapterStart": c1, "verseStart": v1, "chapterEnd": c2, "verseEnd": v2}


def build(cid: str, workers: int, force: bool) -> tuple[dict, dict]:
    meta = PACKS_META[cid]
    books_doc = json.loads(fetch(f"{BASE}/api/c/{cid}/books.json"))
    info = books_doc["commentary"]
    if info.get("licenseUrl") != meta["expected_license"]:
        raise SystemExit(f"license changed upstream: {info.get('licenseUrl')!r}; review before packing")

    jobs = []
    for book in books_doc["books"]:
        first, last = book.get("firstChapterNumber"), book.get("lastChapterNumber")
        if first is None or last is None or not book.get("numberOfChapters"):
            continue
        for chapter in range(first, last + 1):
            jobs.append((book["id"], chapter))

    raw: dict[tuple[str, int], bytes] = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {pool.submit(get_chapter, cid, b, c, force): (b, c) for b, c in jobs}
        for done, future in enumerate(concurrent.futures.as_completed(futures), 1):
            raw[futures[future]] = future.result()
            if done % 200 == 0 or done == len(jobs):
                print(f"   {done}/{len(jobs)} chapters", flush=True)

    articles: list[dict] = []
    truncated: list[str] = []
    seen: set[str] = set()
    skipped_empty = 0
    merged_duplicates: list[str] = []
    chapters_without_text = []
    for book in books_doc["books"]:
        bid = book["id"]
        name = book.get("commonName") or book.get("name") or bid
        last_chapter = book.get("lastChapterNumber") or 1
        intro = (book.get("introduction") or "").strip()
        if intro:
            art_id = f"{bid}:intro"
            seen.add(art_id)
            if len(intro) == UPSTREAM_CUT:
                intro += CUT_NOTICE
                truncated.append(art_id)
            # A book introduction shows with the book's first chapter, not on every page.
            articles.append({"id": art_id, "title": f"Introduction to {name}", "body": intro,
                             "anchor": anchor(bid, 1, 0, 1, END_OF_CHAPTER)})
        for chapter in range(book.get("firstChapterNumber") or 1, last_chapter + 1):
            data = raw.get((bid, chapter))
            if data is None:
                continue
            chap = json.loads(data)["chapter"]
            wrote = False
            cintro = flatten(chap.get("introduction"))
            if cintro:
                art_id = f"{bid}.{chapter}:intro"
                seen.add(art_id)
                articles.append({"id": art_id, "title": f"{name} {chapter}: overview", "body": cintro,
                                 "anchor": anchor(bid, chapter, 0, chapter, END_OF_CHAPTER)})
                wrote = True
            for item in chap.get("content", []):
                if item.get("type") != "verse":
                    continue
                number = item.get("number")
                text = flatten(item.get("content"))
                if not isinstance(number, int) or not text:
                    skipped_empty += 1
                    continue
                art_id = f"{bid}.{chapter}.{number}"
                if art_id in seen:
                    # Upstream occasionally lists one verse twice (2 Samuel 14:27 in Adam
                    # Clarke). Keep both pieces, in order, under one article; record it.
                    existing = next(a for a in articles if a["id"] == art_id)
                    existing["body"] += "\n\n" + text
                    merged_duplicates.append(art_id)
                    continue
                seen.add(art_id)
                articles.append({"id": art_id, "title": f"{name} {chapter}:{number}", "body": text,
                                 "anchor": anchor(bid, chapter, number, chapter, number)})
                wrote = True
            if not wrote:
                chapters_without_text.append(f"{bid} {chapter}")

    attribution = (
        f"{meta['title']} is in the public domain. Text digitized and published by AO Lab's Free Use "
        f"Bible API (https://bible.helloao.org/api/c/{cid}/, {info['licenseUrl']}). "
        f"Source work: {meta['work']} Thruline converted it to plain text, kept verse anchors, "
        f"and did not edit the wording. Greek and Hebrew appear as in the digitization."
    )
    pack = {"id": cid, "title": meta["title"], "author": meta["author"], "attribution": attribution,
            "source": f"https://bible.helloao.org/api/c/{cid}/books.json", "articles": articles}

    manifest = {
        "id": cid,
        "title": meta["title"],
        "upstream": {
            "api": f"{BASE}/api/c/{cid}/books.json",
            "licenseUrl": info["licenseUrl"],
            "licenseNotice": info.get("licenseNotice"),
            "reportedBooks": info.get("numberOfBooks"),
            "reportedChapters": info.get("totalNumberOfChapters"),
            "reportedVerses": info.get("totalNumberOfVerses"),
            "reportedTextDirection": info.get("textDirection"),
        },
        "built": {
            "chapters": len(jobs),
            "articles": len(articles),
            "versesWithoutText": skipped_empty,
            "mergedDuplicateVerses": merged_duplicates,
            "introductionsCutByUpstream": truncated,
            "booksNotCoveredUpstream": [c for c in CANON if c not in {b["id"] for b in books_doc["books"]}],
            "chaptersWithoutText": chapters_without_text,
        },
        "rawChapterSha256": {f"{b}/{c}": sha256(raw[(b, c)]) for b, c in sorted(raw)},
    }
    return pack, manifest


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("commentary", choices=sorted(PACKS_META))
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--force", action="store_true", help="re-fetch chapters even if cached")
    ap.add_argument("--check", action="store_true", help="rebuild and compare with the committed pack")
    args = ap.parse_args()

    pack, manifest = build(args.commentary, args.workers, args.force)
    # Canonical bytes: sorted keys, no extra whitespace, UTF-8 (not ASCII-escaped) so size is honest.
    blob = json.dumps(pack, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    manifest["pack"] = {"file": f"resource-packs/{args.commentary}.json", "bytes": len(blob), "sha256": sha256(blob)}

    out = PACKS / f"{args.commentary}.json"
    man = PACKS / f"{args.commentary}.manifest.json"
    if args.check:
        ok = out.exists() and out.read_bytes() == blob
        print("pack matches committed file" if ok else "PACK DIFFERS from committed file")
        return 0 if ok else 1
    PACKS.mkdir(exist_ok=True)
    out.write_bytes(blob)
    man.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote {out} ({len(blob):,} bytes, {len(pack['articles']):,} articles)")
    print(f"sha256 {manifest['pack']['sha256']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
