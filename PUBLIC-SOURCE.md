# Public source profile

Thruline Bible began as a curated source export of the former Lectern 0.18.0 build 49, not the private working
directory. It builds with the same public study text as the beta. The export keeps
41,233 mixed-rights HCF excerpts out of both source and application, while preserving
604 independently sourced Apostolic Fathers reader sections and author profiles.
Original project code is MIT licensed. Resource and asset terms are separate.

Included: Swift source/tests, public resource snapshots and notices, BSB/KJV/WEB USFM
inputs, the pinned 1870 patristic reader input, icon assets and provenance, importers,
contribution tools, and runtime provenance. No personal notes, API credentials,
Obsidian files, research drafts, old releases, model weights or inference binaries.
The legacy grain texture is omitted because its asset provenance is unresolved;
the existing native gradients render without it. The icon is generated project art,
provided under the code license to the extent copyright applies. System fonts aren't
redistributed. Third-party notices live in Sources/StudyTable/Resources/Licenses.

## Reproducibility boundary

A fresh checkout builds/tests without downloading content or needing private files.
The committed snapshot manifest detects resource drift; the public content check
also rejects unreviewed source IDs and HCF entries. Scripture and the independent
patristic reader can be regenerated from included inputs. Other study/reference
snapshots are included with source and license records, but not every generator's
historical upstream input is included. Do not claim a complete from-upstream
reproducible corpus build. Adding pinned, licensed fetchers for those remaining
inputs is a useful contributor task. Never repopulate HCF as a shortcut.

Use `python3 scripts/verify-public-source.py`. After an intentional, reviewed
resource change, run it with `--write-manifest` and include the resulting diff.
A hash update records bytes; it does not establish rights or theological correctness.
The older `scripts/build-study-resources.py` needs extra upstream inputs and is not
the default public build step. Read each importer's documented prerequisites.

Four HCF-specific historical corpus tests are explicitly skipped in this profile;
alignment logic uses explicitly synthetic text against retained source profiles; public no-HCF assertions, provenance tests, Apostolic Fathers and author-profile
checks remain active. Optional live provider/model tests remain opt-in. Performance
thresholds measure the local machine; hosted-runner failures need investigation,
not deletion of the test.

## Scope of rights evidence

Notices document the included editions and modifications; they are not a blanket
worldwide legal opinion. Gutenberg's edition is public domain in the USA and retains
its full notice. KJV's notice identifies UK restrictions. CC BY material keeps
attribution and license links. Optional downloads and publisher accounts stay separate.

## Historic-works reference index (0.22)

`Sources/StudyTable/Resources/Reference/historic-citations.json` lists, for each optional
Project Gutenberg work in `HistoricWork.catalog`, the Bible references its text cites and
its section titles — no text from the works. It powers "Worth adding for this passage" and
lets the AI recommend books that are not downloaded. Regenerate after changing the
catalogue: download each `https://www.gutenberg.org/cache/epub/<n>/pg<n>.epub` into one
folder, then run `STUDYTABLE_WRITE_CITATION_INDEX=<folder> swift test --filter
CatalogSuggestionTests/testWriteIndex` and record it with
`python3 scripts/verify-public-source.py --write-manifest`.

## Resource packs (0.23)

`resource-packs/` holds prebuilt optional downloads. Unlike the study snapshots above, a pack
is reproducible from its upstream: `python3 scripts/build-helloao-pack.py <id>` fetches the
source chapters, and `--check` rebuilds from cached chapters and compares. The manifest records the
hash of every raw chapter, so a change at the source shows up as a diff rather than silently.
`python3 scripts/test-helloao-pack.py` runs in CI. This is the pinned-fetcher pattern the
reproducibility section asks contributors to extend to the remaining study inputs.
