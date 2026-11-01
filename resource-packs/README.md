# Resource packs

Prebuilt, pinned packs the app can download on request. Each pack is one `ResourceBook`
JSON file plus a manifest recording where it came from and what is known to be missing.
The app checks a pack's SHA-256 against the value compiled into the app and installs
nothing if it differs.

Packs are generated, not hand-edited:

```sh
python3 scripts/build-helloao-pack.py adam-clarke          # fetch, convert, write pack + manifest
python3 scripts/build-helloao-pack.py adam-clarke --check  # rebuild from cached chapters and compare
python3 scripts/test-helloao-pack.py                       # offline checks, run in CI
```

After rebuilding, update the pack's `sha256` and `bytes` in `CommentaryPack.catalog`
(`Sources/StudyTable/ResourceBooks.swift`) and point its URL at the commit that contains
the new file. A rebuild adds a full copy of the pack to git history, so rebuild only for
real changes.

## adam-clarke

*Adam Clarke's Commentary on the Bible* (1810–1826), public domain. Text digitized and
published by [AO Lab](https://helloao.org)'s Free Use Bible API, which records it under the
[Public Domain Mark 1.0](https://creativecommons.org/publicdomain/mark/1.0/). Thruline kept
the wording and verse anchors and changed only the container format.

Known gaps in the upstream digitization, kept visible rather than papered over
(see the manifest for the exact lists):

- Nine books are absent: Deuteronomy, Judges, Psalms, Proverbs, Ecclesiastes, Jeremiah,
  Joel, Malachi and Matthew.
- Five book introductions (Ezra, Job, Song of Solomon, Isaiah, 1 Peter) are cut off
  mid-sentence by the source; the pack says so at the cut.
- 2 Samuel 14:27 is listed twice upstream; both pieces are kept in one article.
- The API's record labels this English text right-to-left, which looks like a data error.

Do not read this commentary's silence on a passage as a view of the author's. Where a book
is missing here, the work still has something to say; this digitization simply lacks it.
