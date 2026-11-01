<p align="center"><img src="Assets/AppIcon-1024.png" width="128" alt="Thruline Bible app icon: a lit cross above a winding path"></p>

# Thruline Bible

[![Contributor checks](https://github.com/fastermatt/thruline-bible/actions/workflows/checks.yml/badge.svg?branch=main)](https://github.com/fastermatt/thruline-bible/actions/workflows/checks.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Jesus is the throughline of Scripture. Study the Bible with the Church, across centuries.**

Thruline Bible (formerly Throughline) brings Scripture,
historical sources, original-language tools and your own notes into one quiet
workspace. Open a passage, follow its sources, and keep what you learn. The included core works offline, without a subscription, account or AI
service.

[Download the Thruline Bible Mac beta](https://github.com/fastermatt/thruline-bible/releases/latest)
· [See what you can do](#what-you-can-do-today)
· [Help build Thruline](#help-build-thruline)

![Thruline passage study in light mode](docs/images/study-romans-light.png)

[View dark mode](docs/images/study-romans-dark.png)

## Why Thruline exists

For centuries, Christians have copied, translated, preserved, debated and explained
Scripture. Much of that work can be shared freely, yet finding a trustworthy edition
and using it alongside a passage can still be difficult. Thruline brings those texts
into reach with clear attribution and room for the reader's own work.

We want serious study to be available whether or not someone can pay. The official
core remains free; optional publisher books and personal AI services are separate
choices. We take historic Christian teaching seriously: disputed or rejected claims
need specific evidence and room for correction, not a verdict based only on an
author's name. AI output cannot approve those claims.

Thruline is built in public so readers, researchers, translators, accessibility
testers, writers and developers around the world can improve it. We credit their
work and explain editorial decisions. The project should be able to grow beyond
any one founder.

## What you can do today

- **Read and search Scripture offline.** BSB, KJV and WEB are included. Move from a
  passage to its cross-references and linked sources without leaving your study.
- **Follow the historical record.** Read passage-linked commentaries and reference
  entries with author, edition and source information. Coverage varies by passage.
  A separate, searchable Apostolic Fathers reader and 74 author profiles are included.
- **Learn as you read.** Follow Read → Words → Grammar → Reflect. Plain-English
  help covers ten Greek/Hebrew verb features, with source links. Optional emphasis
  notes cover three BSB examples; reflections save as passage-linked notes.
  [See the learning guide](WORKSPACE-AND-LIBRARY.md#guided-passage-study).
- **Study original-language words.** Use Strong's numbers, lexicon entries,
  concordance results and Greek or Hebrew word tools with their source context.
- **Use separate windows.** Detach Bible, Sources & tools, or Notes with the pane
  button or View menu. Pin a sermon note while browsing, then return the panes to
  the workspace. Notes share one live editor session and the existing saved data.
  Saved layouts remember separate windows, and open windows come back after relaunch.
- **Keep your work.** Write passage-linked notes, save and highlight verses, organize
  collections, and export study work. Save a favorite layout; adjust reading type,
  light/dark colors and optional navigation tips.
- **Grow your library.** Add free Bible editions in English and eight other
  languages, Tyndale study notes and a dictionary, and Church Fathers such as
  Augustine, Ambrose, Chrysostom and Origen; import your own unencrypted EPUB or plain-text books. Included and
  downloadable resources disclose their rights and provenance; importing a book
  does not grant redistribution rights. [See the library guide](WORKSPACE-AND-LIBRARY.md).
- **Use AI only if it helps.** Choose one of three optional local models, connect
  your own compatible provider, or let an external AI use Thruline's read-only JSON
  CLI. None is needed for core study. [See AI and CLI](CLI-AND-AI.md).

## Get Thruline

[Download the latest Thruline Bible beta](https://github.com/fastermatt/thruline-bible/releases)
for an **Apple Silicon Mac running macOS 14 or later**. The current beta is
ad-hoc signed and not Apple-notarized. Follow the [installation and update guide](docs/INSTALL.md)
for the exact steps. From 0.22 the app updates itself in one click. No account is needed for the included
study resources.

## Help build Thruline

You do not need to write Swift or own a Mac to help. Try one study session and report
where you got stuck; check a citation or resource edition; improve a translation,
help page or accessibility path. Small, well-sourced contributions matter.

- [Report an installation problem](https://github.com/fastermatt/thruline-bible/issues/1)
  or [ask a question](https://github.com/fastermatt/thruline-bible/discussions).
- [Pick a good first issue](https://github.com/fastermatt/thruline-bible/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22),
  including [accessibility](https://github.com/fastermatt/thruline-bible/issues/2),
  [localization](https://github.com/fastermatt/thruline-bible/issues/3) and
  [reproducible resources](https://github.com/fastermatt/thruline-bible/issues/4).
- [Help share maintenance](https://github.com/fastermatt/thruline-bible/issues/5) so the
  project can continue without one person's constant attention.

Start with [Contributing](CONTRIBUTING.md) and the [roadmap](docs/ROADMAP.md). Work
can be submitted asynchronously and in your preferred language. Reviews explain
what evidence or checks a change needs; AI-assisted contributions require the same
human verification as other work. See the [conduct](CODE_OF_CONDUCT.md),
[security](SECURITY.md) and [architecture](docs/ARCHITECTURE.md) guides. There is no
promised response time or staffed editorial board yet.

## Build and test

Use a Mac with full Xcode and its Swift 6 toolchain, Python 3.9+, and Git. The current
beta and bundled local engine target **Apple Silicon, macOS 14+**. The local verification
record is in [Validation](docs/VALIDATION.md); the badge above links the current hosted CI result. Windows/Linux contributors can use the Python validators and edit docs/data.

```sh
git clone https://github.com/fastermatt/thruline-bible.git
cd thruline-bible
# Run inside your clone. Accept Xcode's license through Xcode if prompted.
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
python3 scripts/verify-public-source.py
swift build
swift test
swift run StudyTable
```

No Obsidian vault, maintainer account, API key, model or upstream corpus download is
needed. `StudyTable` remains the internal module name to preserve compatibility.

To build an installable beta with the optional local engine:

```sh
python3 scripts/bootstrap-local-ai.py   # pinned 16.5 MB engine; no model weights
scripts/verify-content.sh
scripts/package-app.sh                 # writes Releases/Thruline-Bible-<version>.zip
```

The packager refuses to overwrite an existing release. Update Info.plist for a new
version. This produces an **ad-hoc signed, unnotarized** beta; it does not publish to
GitHub or provide automatic app updates. See [release instructions](docs/RELEASING.md).

## Resources and trust

Original code, tests and documentation are MIT licensed. The adapted unfoldingWord
grammar lesson prose is separately CC BY-SA 4.0. Scripture, datasets, books
and assets keep their own terms; see [LICENSE](LICENSE), [content sources](CONTENT-SOURCES.md)
and [third-party notices](THIRD_PARTY_NOTICES.md). The included public-source profile
withholds mixed-rights HCF excerpts, private inputs and unverified legacy texture art.
The separate Apostolic Fathers reader remains included. See [PUBLIC-SOURCE.md](PUBLIC-SOURCE.md)
for exact scope, regional rights notices and the limits of corpus regeneration.

## Thanks

Thruline stands on open work by others. The Matthew Henry, John Gill, Keil & Delitzsch,
Jamieson-Fausset-Brown and Calvin commentaries are digitized and published by
[AO Lab](https://helloao.org) through the
[Free Use Bible API](https://bible.helloao.org), a 501(c)(3) nonprofit project. Cross-references
come from the Treasury of Scripture Knowledge, original-language data from STEPBible
(Tyndale House), and the Berean Standard Bible and World English Bible texts from eBible.org.
Adam Clarke's commentary is an optional download built from the same source. Each work keeps its
own notice; see [third-party notices](THIRD_PARTY_NOTICES.md).

Source quotations, editorial interpretation and historical reception are distinct.
The app does not declare one fixed confessional identity; the reader can choose a
comparison lens. Source-based cautions remain visible. Disagreement with a chosen
tradition is not automatically a finding of heresy. Contributions to doctrinal labels
need primary evidence and human review; see [review process](GOVERNANCE.md).
