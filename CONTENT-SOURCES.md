# Content sources and labeling

## Apostolic Fathers reader and reception guide — 0.17 (2026-10-28)

The independently sourced offline reader uses Project Gutenberg #77576, *The Writings of the Apostolic Fathers*, Ante-Nicene Christian Library I (T. & T. Clark, 1870), edited by Roberts/Donaldson, translated by Roberts/Donaldson/Crombie. Official record: https://www.gutenberg.org/ebooks/77576 (public domain in the USA, not a worldwide rights assertion). Full license, source credits and use notice are available inside the reader and bundle. The pinned raw text is `work-content/apostolic-fathers-77576.txt`; regenerate with `scripts/build-patristic-reader.py`. Resource provenance includes raw/output/license SHA-256s. All 5,727 normalized source paragraphs are retained across 604 reader sections (including notices/license). Recensions and spurious appendix titles are explicitly distinguished; this is not a claim of universal authenticity or a full ANF/NPNF corpus.

The packaged beta still withholds 41,233 separate HCF verse-linked excerpts pending edition-level rights verification. The new Reference reader does not circumvent that gate. Existing 74 author profiles are discoverable independently of installed author works. Corrected stale research-tier warning: Origen and Tertullian are historic witnesses with reception notes, not blanket-excluded authors. A synodal judgment for schism is not automatically a Trinitarian heresy verdict.

`ReceptionGuide.swift` contains editorial comparisons with source links. **0.17.1 correction (2026-10-28):** Jung’s entry now names doctrinal conflict, rather than only modern origin. Primary-text verification: *Answer to Job*, CW 11 §§661–662, R. F. C. Hull translation, Princeton edition (ISBN 9780691150475). Compare God’s goodness and Christ’s death for human sin in 1 John 1:5, 1 Corinthians 15:3 and Romans 5:8. The app links the publisher’s edition record; it does not claim that record displays the cited paragraphs. Research checked the actual text in the online book scan at https://cdnimpuls.com/politiko.al/uploads/2019/09/C.-G.-Jung-Answer-to-Job-Princeton-University-Press-1952.pdf (PDF pages 73–75, one-based). The user’s *Jung vs Gospel.pdf* prompted review; its secondary-source claims were not automatically adopted. No copyrighted Jung text or user PDF is bundled.

Categories distinguish doctrinal conflict, later framework, early refutation and council judgment. The remaining historical comparisons cite Ignatius *Smyrnaeans* 1–4, Irenaeus *Against Heresies* I.9–10 and Nicaea (325). No ancient council is invented for Jung, no automatic classification of user books is performed, and no comprehensive theological review or new confessional constitution is claimed. This is an editorial comparison of named propositions, not a blanket assessment of psychology or every Jungian practitioner. (Codex)


## Bible text

Bundled translations (all from eBible.org, all public domain; USFM sources kept in `scripture-source/`, compact packs in `Sources/StudyTable/Resources/Scripture/`, regenerated with `scripts/build-scripture-packs.sh`):

- **BSB** — Berean Standard Bible, BSB Publishing, LLC. <https://ebible.org/engbsb/>
- **KJV** — King James Version, standardized 1769 text, protocanon (`eng-kjv2006_usfm.zip`, courtesy of the CrossWire Bible Society and eBible.org). Public domain outside the UK, where Crown letters patent govern *printing*.
- **WEB** — World English Bible, 2020 stable text, protocanon (`engwebp_usfm.zip`). Public domain; the name is an eBible.org trademark.

ESV, NASB and NKJV are **not bundled**. ESV (Crossway API) and NKJV (API.Bible) can be read online with the user's own API key within each publisher's terms; a licensed offline pack for any of them can be installed in the existing `~/Library/Application Support/StudyTable/Translations/` data folder.

## Offline study indexes

The Study Desk is generated as per-chapter indexes (`Resources/Study/<CODE>/<CHAPTER>.json`,
one file per Bible chapter — changed from one file per book in 0.7 once Gill and Matthew Henry
Complete made the largest books' single-file size a cold-book-switch performance risk) and
follows the selected verse. It can display all enabled banks at once:

- **Matthew Henry's *Commentary on the Whole Bible*, Complete/unabridged** — Public Domain Mark
  1.0, digitized by the HelloAO Free Use Bible API (`https://bible.helloao.org/api/c/matthew-henry/`).
  Replaces the *Concise Commentary* bundled through 0.6.x as the primary Henry voice (retired
  2026-09-22: two Henry cards per verse was clutter, and the Concise is an abridgment of this
  same work). Verified coverage gaps in this digitization, not this app's own parser: no Song of
  Solomon at all (65 of 66 books); 2 Samuel stops at chapter 22 of 24; Jonah stops at chapter 1
  of 4; Matthew stops at chapter 18 of 28 (missing 19–28, including the Passion narrative); 8
  further chapters are individually empty within otherwise-complete books (Numbers 31–35, Joshua
  22–23, Psalm 72). **Since 0.7 wave 2 (E3, 2026-09-23) every one of these 31 chapters is
  backfilled** with Matthew Henry's *Concise* Commentary, labelled "Concise Commentary" on its
  card, so Henry's own voice (abridged, where the Complete has nothing) now covers them too —
  see `data/study-build-report.json`'s `mhccGapFill` for the exact, build-recomputed list. No
  chapter of the canon is left with zero Reformed (Tier 1) commentary — Calvin and/or Henry
  (Complete or Concise backfill) cover every gap.
- John Calvin's commentaries — public-domain text converted by the MIT-licensed Pillar Commentary
  Data project; available for Calvin's covered books. **Isaiah 49–66 gap-fill (2026-09-24,
  workstream M, 0.9.5):** the cached Pillar conversion has empty `content: []` for Isaiah 49–66 —
  the entire Book of Consolation, including the Servant Songs and Isaiah 53 — confirmed as a
  genuine upstream gap (a fresh fetch of the same Pillar/CrossWire conversion from the jsdelivr
  CDN mirror is also empty for these 18 chapters; this is not a local corruption or a parser bug).
  HelloAO's own independent digitization of the same Calvin Translation Society English text
  (`https://bible.helloao.org/api/c/john-calvin/`, Public Domain Mark 1.0, verified against
  `available_commentaries.json`) has real content for all 18 chapters — confirmed the same
  underlying translation by comparing Isaiah 1:1, which both sources cover. Integrated as a
  narrow gap-fill source (`calvin-helloao`, `work-content/helloao/calvin-helloao/ISA/49.json`
  through `66.json` only) through the same generic HelloAO commentary parser already used for
  Gill/Henry/Keil-Delitzsch/JFB — chapters 1–48 keep shipping unchanged from the primary `calvin`
  source, and no chapter ever carries Calvin from both sources at once (tested). Known,
  cosmetic-only quirk of this specific digitization, left as-is rather than "corrected": Hebrew
  words render as a bare consonantal Latin-letter transliteration (e.g. "chzvn") instead of the
  Pillar copy's Hebrew Unicode glyphs (e.g. "חזון") — same word, different rendering, does not
  affect the English commentary text. See
  `work-content/helloao/calvin-helloao/_fetch-manifest.json` and
  `Sources/StudyTable/Resources/Licenses/commentary-calvin-helloao-Public-Domain.txt`.
  **Psalms (0.10, workstream R2, 2026-09-26).** The same Pillar conversion carries, for 148 of the
  150 psalms, ONE text repeated in every verse slot (the psalm's introduction, its title comment and
  the commentary on its first verse group only) — Ps 22 was one 2,240-word "block" under every verse
  that never mentions "pierced". HelloAO's `john-calvin` PSA/1–150 (fetched into
  `work-content/helloao/calvin-helloao/PSA/`) has the real per-verse commentary. **Precedence rule**
  (`build_calvin_psalms()` in `scripts/build-study-resources.py`, tested in `CalvinPsalmsTests`):
  (1) chapters where Pillar has genuine per-verse text keep Pillar and do not use HelloAO (Ps 55, 120);
  (2) chapters where Pillar has only the repeated block ship HelloAO's commentary instead, split at
  each verse-numbered paragraph (so Ps 22:16 opens "16. They have pierced my hands and my feet…") —
  146 chapters, 1,688 entries; (3) the psalm's introduction, which HelloAO's digitization lacks, is the
  one piece of Pillar text kept beside it: one entry per psalm anchored at verse 1 (144 psalms), so a
  chapter carries Calvin from both sources but never the same text twice; (4) fallback to the Pillar
  block when HelloAO is missing/unparseable or fails the same-translation gate (Ps 53 and 70: Calvin
  wrote no separate commentary, HelloAO has only the quoted psalm). **Same translation, verified:**
  ≥ 90% of every chapter's Pillar 6-word shingles occur in HelloAO's chapter (median 100%, min 91.6%);
  in Ps 55 and 120, where both sources have per-verse text, every verse matches at 91–100% word-sequence similarity (12 of 18 at ≥ 99.7%; the rest differ only where Pillar's verse card is longer). **Not
  shipped:** the CTS translator's footnotes (partly French) and the inline `[n]` markers that pointed
  at them (also removed from Isaiah 49–66, where 0.9.5 had shipped 488 dangling markers), the group
  header, the inscription line, and Calvin's quoted rendering of each verse group. **One upstream
  misfiling repaired:** HelloAO files the group for Psalm 104:19–22 inside Psalm 102's item (header
  mislabelled); it is re-homed to Ps 104 with the text untouched. Still one whole-psalm card: Ps 53
  and 70 (above) and Ps 108 and 117 (Calvin's own layout is a single passage-level comment). Verses
  Calvin's own text skips (e.g. Ps 136:17–22, "the six verses taken from the previous Psalm I pass
  over"; Ps 34:15–17; Ps 90:14–15; Ps 104:23) show no Calvin card. Other Calvin books with the same
  one-block-per-chapter shape (not touched here): 1 Timothy, 2 Timothy, Titus, Malachi, Zechariah —
  31 chapters.
- Treasury of Scripture Knowledge cross-reference data — CC BY 4.0, mapped to the BSB versification.
- **Church-father extracts — mixed-rights Historical Christian Faith Commentaries Database
  material, broadened 2026-09-23 (0.8, workstream I).** Rights correction reviewed
  2026-10-27 (Codex): upstream dedicates its compilation and public-domain excerpts
  to the public domain, but expressly excludes modern copyrighted excerpts from
  that dedication. Those retain their original rights, and downstream distributors
  must assess their own use. This bank is not cleared for unrestricted redistribution;
  permission must be verified per work and translation. The exact current upstream
  notice and URL are preserved in `Resources/Licenses/Historical-Christian-Faith-Public-Domain.txt`
  (under `Sources/StudyTable/`); the retained filename is not a blanket PD claim. Matt: *"I don't want only reformed church
  fathers listed, but I want the user to know the church fathers' theological bent."* The default
  Fathers bank moved from a 21-name curated whitelist to a rule-based admission covering every
  patristic-era author the database files under Early Fathers (Pre-Nicaea), Eastern & Byzantine
  Theology, Syriac & Oriental Theology, or the patristic part of Western & Medieval Theology,
  through c. AD 800 — 209 authors (204 with surviving in-canon content; see
  `data/study-build-report.json`'s `fathersAdmission`), except council-condemned figures (see
  below) and the Pseudonymous Works / Apocrypha categories (unchanged, excluded entirely). Origen,
  Tertullian, Clement of Alexandria and Eusebius of Caesarea — previously held back to the
  research-only bucket — are now default-visible, each carrying a sourced theological profile
  that states their disputed-reception nuance precisely rather than omitting it.
  - **Theological profiles** (`Resources/Study/fathers-profiles.json`, generated from the
    hand-curated `work-content/fathers-profiles.source.json`): school/tradition, region, see,
    language, dates, ecclesial recognition, 1–3 emphases, and controversies/conciliar judgment,
    each field sourced from a specific public-domain reference — Wace & Piercy's 1911 *Dictionary
    of Christian Biography and Literature to the End of the Sixth Century* (a faithful,
    article-for-article PD transcription is mirrored on Wikisource; the original is also on CCEL)
    for every author within its stated 6th-century scope, and Schaff's NPNF for the one author
    outside it (John Damascene). 60 of the 209 default/condemned authors have a written profile so
    far — the highest-content-volume names plus every council-condemned one — surfaced in-app via
    `FatherBentLabel` (a compact "School · emphasis" chip on the source card) and
    `FatherProfileSheet` (the full sourced profile). A profile-less admitted author's card simply
    shows no label; this is a coverage gap, not a defect, and is real future work like the
    whitelist itself always was.
  - **Council-condemned bucket** (Tier 3, opt-in toggle, unchanged UI): 9 authors, each labelled
    with the specific council/synod + year a real source documents — Arius (Nicaea, 325),
    Apollinaris of Laodicea (Constantinople I, 381), Pelagius and Julian of Eclanum (Ephesus, 431),
    Novatian (Roman synod under Cornelius, 251), Theodore of Mopsuestia (Constantinople II, 553 —
    added by overriding the database's own `condemned_by_council=0` flag after verifying the Three
    Chapters condemnation against Wace & Piercy directly). Heracleon, Valentinus and Tatian the
    Assyrian are flagged condemned in the database and kept out of the default bank on that basis,
    but predate the conciliar era entirely — their profiles say so honestly instead of inventing a
    "council + year" no source documents.

**Exegetes bank (Tier 2, new 0.7 wave 2, E1/E2, 2026-09-23)** — genuinely valuable, historic
whole-Bible or Old-Testament exegetes who are not confessionally Reformed. Every card names its
author's own tradition:
- **John Gill's *Exposition of the Old and New Testament*** — Public Domain Mark 1.0, digitized
  by the HelloAO Free Use Bible API (`https://bible.helloao.org/api/c/john-gill/`); verse-by-verse
  across all 66 books. Gill was a Particular Baptist, not a Westminster subscriber — moved out of
  the Reformed bank into Exegetes (labelled "Particular Baptist") per Matt's original spec, which
  `CONTENT-ROADMAP.md` had already flagged as the correct call; an earlier 0.7 wave-1 pass had
  filed him Tier 1 pending this decision, which E1 now resolves.
- **Keil & Delitzsch's Old Testament Commentary** — Public Domain Mark 1.0, digitized by the
  HelloAO Free Use Bible API (`https://bible.helloao.org/api/c/keil-delitzsch/`); 39 Old Testament
  books, labelled "Lutheran". 11 individual chapters and all of Song of Solomon are missing at
  the source itself (upstream gap, not a parsing defect — see
  `work-content/helloao/keil-delitzsch/_fetch-manifest.json`).
- **Jamieson, Fausset & Brown's Commentary Critical and Explanatory on the Whole Bible** — Public
  Domain Mark 1.0, digitized by the HelloAO Free Use Bible API
  (`https://bible.helloao.org/api/c/jamieson-fausset-brown/`); all 66 books, labelled
  "Presbyterian & Anglican".

Every entry carries a deterministic ID, a reference into `sources.json` (title, publisher, licence, URL, review state) and a range basis (`stated`, `anchored`, `block`). `data/study-build-report.json` records what the build cleaned or dropped and the SHA-256 of every raw input. The Calvin conversion required cleaning (next-book/next-chapter text, whole-chapter blocks repeated per verse); Gill/Henry/Keil-Delitzsch/Jamieson-Fausset-Brown needed a double-encoded-UTF-8 (mojibake) repair and a rare literal-emphasis-marker strip; the Concise Commentary gap-fill needed a one-off leftover-RTF-control-word repair (`\rdblquote`, one isolated occurrence in the whole file); a handful of pre-existing Fathers rows had stray literal backslash escapes. All rules are in the script header/comments, `scripts/build-study-resources.py`.

Source cards distinguish source text from indexed canonical links and retain a provenance URL where supplied. “Received Father” means the author passed the stated historical filter; it is not a claim that every statement agrees with the Westminster Confession. "Exegete" means the author is a settled, named, received whole-Bible or Old-Testament commentator who is not confessionally Reformed; the tradition label on each card says which he actually was. Reformed sources, Exegetes and canonical links remain visually separate from historical witnesses and from each other.

**Fathers cards with no work-specific source URL (2026-09-24, workstream M, 0.9.5).** Every Fathers
row without its own `sourceURL` falls back, in the app (`Models.swift`'s
`ResolvedSource.provenanceURL`), to the whole Historical Christian Faith repository rather than
the specific work. A full scan of the source database found this is **9,372 shipped entries
across 6,714 distinct author/work combinations** — not the "23" figure recorded from a 0.9.3
pastor-QA spot-check sample (that number was a sample size, not the true population; corrected
here). The Historical Christian Faith database itself has no `source_url` for these rows (verified
directly against `commentaries.sqlite`: 17,307 of 91,796 raw rows have an empty `source_url`
string, and only 98 of those are recoverable by borrowing a sibling row's URL for the identical
work — not a meaningful fraction). `FATHERS_SOURCE_URL_OVERRIDES` in `build-study-resources.py`
holds one hand-verified addition this pass — **Theodoret of Cyrus, "Interpretation of the Letter
to the Romans"** → an 1839–40 English translation (Christian Remembrancer, translator unrecorded,
no modern copyright holder) hosted at tertullian.org, confirmed by direct fetch to be the actual
work text. Several other high-volume candidates (Ambrosiaster's *Commentary on Paul's Epistles*,
Pelagius's *Commentary on Romans*, Ephrem the Syrian's purported *Commentary on the Epistle to the
Hebrews* — which does not appear in any attested list of Ephrem's actual works and may itself be a
database mis-titling worth a future look) were checked and rejected: either no free specific page
could be found, or the only modern English translation is a copyrighted scholarly edition (e.g.
Pelagius via de Bruyn/Oxford 1993), which this app will not link to in place of a public-domain
source. Hand-curating the remaining ~6,713 combinations is not attemptable within honest,
verified effort — see `CONTENT-ROADMAP.md` for the proposed UI-facing fix (distinguishing "linked
to this specific work" from "linked to the source database only") that scales to the real size of
this gap.

## Passage Guide reference indexes — specificity (0.10, workstream R2)

Nave's Topical Bible and Easton's Bible Dictionary (public domain, CrossWire SWORD modules; see
`scripts/reference-sources/SOURCES.md`) drive the desk's Topics and Dictionary sections. The 0.10
pastor QA found SIN, ROME and RIGHTEOUS on every verse of Romans 8:28–39 and GERIZIM / TEMPLE,
SOLOMON'S on every verse of Genesis 22. **Diagnosis** (`scripts/build-reference.py`): the per-verse
index attached a heading to every verse of every span that cites it, at full weight and sorted
alphabetically — and a topic or article that only cites "Rom. 8" (a bare chapter; 27% of all Nave
verse links, 18% of Easton's own) or a long run ("Rom. 2–9", "Gen. 22:1–14") looks identical to one that
cites the verse itself. Easton also inherits every Nave topic whose name equals an Easton headword
(80,196 of its 137,050 links), so Nave's wide citations re-entered there. **Fix** (per-verse direction
only; topic → all-verses lists and the article/topic detail files are byte-identical): each (verse,
heading) takes the *narrowest* citing span that covers it; ≤ 10 verses (or the heading is named in the
verse's own BSB text) = a direct hit, ranked narrowest span first, then smaller topic, then name, capped
at 12 (Nave) / 8 (Easton) in `verse-index/`; everything else — wide citations and any cap overflow —
goes ranked into `verse-index-more/`, which the desk shows behind a "N more · cited in wider passages"
control. Nothing is deleted. Before/after numbers for the 0.10 build are in the R2 handoff report.


## Optional Tyndale text downloads (0.14, 2026-10-27)

Official source: https://tyndaleopenresources.com/ . The application downloads directly on reader request; nothing is bundled or fetched at startup. Each archive README licenses the content under CC BY-SA 4.0 and supplies an adaptation attribution. Open Study Notes is copyright 2022; Open Bible Dictionary is copyright 2023, both Tyndale House Publishers. Thruline converts the XML to plain-text articles, omits illustrations/layout and links supplied passage scopes; the converted content carries that same license and declares the changes. Installed JSON includes the notice and license URL, independent of the app's source-code license.

Reviewed SHA256: study notes `7b4d5ae088449d5a6925170c4b89b978acee2f78f73dc6b8a278fa948a7e8498`; dictionary `10758ea00dbea7540f9337e43e59c8e4000295c1261e3426bab6f31c31dcff5b`. A new upstream version requires catalog review; checksum mismatches are not bypassed. Verified conversion: 17,478 study-note/intro/summary/profile/theme records, 6,120 dictionary article/textbox records. All 16,923 StudyNote records have usable passage anchors. Modern author commentary is attributed as source material, never an automatic statement of theological agreement.

Personal EPUB/TXT imports stay in the reader's local ResourceBooks directory. Importing does not confer distribution permission. Publisher-store links are outbound navigation, not purchases or automatic entitlements. No DRM removal is implemented. (Codex)

## Optional commentary pack: Adam Clarke (0.23, 2026-11-01)

*Adam Clarke's Commentary on the Bible* (1810–1826) is an optional free download, not bundled. Source: the HelloAO Free Use Bible API (`https://bible.helloao.org/api/c/adam-clarke/`), whose record gives the Public Domain Mark 1.0. `scripts/build-helloao-pack.py` fetched all 854 chapters once, converted them to a `ResourceBook` pack at `resource-packs/adam-clarke.json` (14,205 articles), and wrote `resource-packs/adam-clarke.manifest.json` with the hash of every raw chapter, the pack's SHA-256 and the known gaps. The app does not call the API; it downloads that one file at a pinned commit and refuses it unless its size and SHA-256 match. Thruline kept the wording and verse anchors. Book introductions are anchored to chapter 1.

Gaps in the upstream digitization, not Thruline's parser, and shown in the app's description of the pack: nine books are absent (Deuteronomy, Judges, Psalms, Proverbs, Ecclesiastes, Jeremiah, Joel, Malachi, Matthew); the introductions to Ezra, Job, Song of Solomon, Isaiah and 1 Peter are cut off mid-sentence at exactly 32,767 characters, and the pack marks each cut in the text; 2 Samuel 14:27 is listed twice upstream and both pieces are kept in one article; the API labels this English text right-to-left. Clarke is a Wesleyan author writing before 1830; the pack carries no doctrinal label of its own, and any in-app doctrinal category for it needs the human review GOVERNANCE.md requires.
