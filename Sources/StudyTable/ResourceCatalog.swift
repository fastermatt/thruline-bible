import Foundation

/// Access and rights are separate: being present in this beta does not establish
/// permission to redistribute a text. This catalogue never grants publisher rights.
enum ResourceAccessGroup: String, CaseIterable, Identifiable, Sendable {
    case included = "Included offline"
    case downloads = "Free downloads"
    case ownAccount = "Own account or licensed pack"
    case rightsReview = "Rights review"

    var id: String { rawValue }
}

struct StudyResourceInfo: Identifiable, Sendable {
    let id: String
    let title: String
    let access: ResourceAccessGroup
    let detail: String
    let rights: String
    let sourceURL: URL
}

enum ResourceCatalog {
    static let coreAccessSummary = "The included library works offline, without an account, subscription or paid AI. It does not depend on the developer’s accounts. Optional downloads need internet; publisher editions use your own access."

    static let resources: [StudyResourceInfo] = [
        .init(id: "apostolic-fathers", title: "Church Fathers & historical reception", access: .included,
              detail: "The Writings of the Apostolic Fathers (1870): Clement, Ignatius, Polycarp, Hermas, Papias and related writings. Read and search the volume offline; inspect author profiles and sourced comparisons of Jungian readings, docetism, Valentinian teaching and Nicaea. Not the complete patristic corpus. Bible references in the text are detected and linked to passages.",
              rights: "Project Gutenberg #77576: public domain in the USA; laws elsewhere may differ. Edition, license and disputed/spurious attributions retained. Modern comparison notes are editorial summaries with source links, not bundled modern books.",
              sourceURL: URL(string: "https://www.gutenberg.org/ebooks/77576")!),
        .init(id: "scripture", title: "BSB, KJV and World English Bible", access: .included,
              detail: "Three complete, 66-book Bibles. Read, search and compare without a connection.",
              rights: "Public domain. KJV has UK printing restrictions; World English Bible has a naming and trademark condition.",
              sourceURL: URL(string: "https://ebible.org/Scriptures/")!),
        .init(id: "commentaries", title: "Historical commentaries", access: .included,
              detail: "Calvin, Matthew Henry Complete with Concise gap-fill, John Gill, Keil & Delitzsch, and Jamieson–Fausset–Brown. Coverage varies by work.",
              rights: "Historic public-domain texts, most digitized by AO Lab’s Free Use Bible API. Calvin’s Pillar conversion also carries an MIT notice. Each card identifies its source.",
              sourceURL: URL(string: "https://bible.helloao.org/api/available_commentaries.json")!),
        .init(id: "word-study", title: "Original languages and word study", access: .included,
              detail: "Hebrew, Aramaic and Greek words, morphology, edition and variant flags, Strong’s definitions, and concordances. English word matching is a labelled heuristic.",
              rights: "STEPBible data: CC BY 4.0, Tyndale House Cambridge / STEPBible.org. Strong’s dictionaries: public-domain editions.",
              sourceURL: URL(string: "https://github.com/STEPBible/STEPBible-Data")!),
        .init(id: "passage-guide", title: "Topics, dictionary, people and places", access: .included,
              detail: "Nave’s Topical Bible, Easton’s Bible Dictionary and book introductions, and STEPBible TIPNR names. TIPNR descriptions include source-supplied AI drafts; they are bundled source text, not generated on demand.",
              rights: "Nave and Easton: public domain. TIPNR: CC BY 4.0, Tyndale House Cambridge / STEPBible.org.",
              sourceURL: URL(string: "https://github.com/STEPBible/STEPBible-Data")!),
        .init(id: "cross-references", title: "Scripture cross-references", access: .included,
              detail: "Treasury of Scripture Knowledge-derived passage links from CrossReferences.org, indexed to BSB references.",
              rights: "CrossReferences.org data: CC BY 4.0. These are reference links, not commentary or doctrinal endorsements.",
              sourceURL: URL(string: "https://github.com/CrossReferences-org/bible-cross-references")!),
        .init(id: "standards", title: "Historic confessions and catechisms", access: .included,
              detail: "Westminster Confession, Larger and Shorter Catechisms, Heidelberg Catechism, Belgic Confession, and the Canons of Dort’s positive articles, with proof texts. Dort’s Rejection of Errors is not included.",
              rights: "Historic public-domain English texts; modern restricted translations are excluded. Proof-text links are distinct from human-reviewed alignment badges.",
              sourceURL: URL(string: "https://www.ccel.org/creeds/")!),
        .init(id: "tyndale", title: "Tyndale Open Study Notes & Bible Dictionary", access: .downloads,
              detail: "One-click optional downloads in Add resources. Study notes follow Bible passages; both resources support offline reading and text search.",
              rights: "Tyndale House Publishers · CC BY-SA 4.0. Thruline’s attributed text adaptation omits illustrations and retains the same license.",
              sourceURL: URL(string: "https://tyndaleopenresources.com/")!),
        .init(id: "commentary-packs", title: "Adam Clarke’s Commentary (optional)", access: .downloads,
              detail: "A Wesleyan verse-by-verse commentary (1810–1826), downloaded once from a pinned file and then read and searched offline. It appears beside your passage in the Study Desk. The digitization lacks nine books (Deuteronomy, Judges, Psalms, Proverbs, Ecclesiastes, Jeremiah, Joel, Malachi and Matthew).",
              rights: "Public Domain Mark 1.0 as recorded by AO Lab’s Free Use Bible API. Thruline checks the file’s SHA-256 and installs nothing if it differs. Inclusion is not doctrinal endorsement.",
              sourceURL: URL(string: "https://bible.helloao.org/api/c/adam-clarke/books.json")!),
        .init(id: "offline-bibles", title: "Additional offline Bibles", access: .downloads,
              detail: "English: ASV, Young’s Literal, Darby, Webster, Geneva 1599, Revised Version 1885 and Majority Standard Bible. Also Spanish, French, German, Italian, Czech, Russian, Ukrainian and Chinese historic editions. Download once, then read offline. No account needed.",
              rights: "Public-domain editions from eBible.org. Text only, without source footnotes; verse numbering can differ.",
              sourceURL: URL(string: "https://ebible.org/Scriptures/")!),
        .init(id: "historic-works", title: "Church Fathers and classic Christian works", access: .downloads,
              detail: "Augustine (Confessions, City of God, Donatist writings), Ambrose’s letters, Chrysostom selections, Origen, Hippolytus, Ayer’s Source Book, Bede and Boethius, plus Calvin’s Institutes and The Imitation of Christ. Download once, then read and search offline. Bible references inside them are detected and linked, and the Study Desk shows which books cite your passage — even before you download them.",
              rights: "Project Gutenberg editions: public domain in the USA; laws elsewhere may differ. Historic translations and their notes are the translators’ own. Gutenberg regenerates files, so each install records the file’s SHA-256 rather than relying on a pinned checksum.",
              sourceURL: URL(string: "https://www.gutenberg.org/")!),
        .init(id: "tcp-reading", title: "Puritan Library", access: .downloads,
              detail: "Historic TCP work and volume downloads with a basic reader and table of contents. These books are not yet linked by verse to the Study Desk.",
              rights: "Text Creation Partnership transcriptions are public domain; its catalogue list is CC0. This covers text, not publisher facsimile images.",
              sourceURL: URL(string: "https://www.textpartnership.net/pages/faq.html")!),
        .init(id: "esv", title: "English Standard Version", access: .ownAccount,
              detail: "Online through your own Crossway API key. Network and publisher limits apply; the limited cache is not a complete offline Bible.",
              rights: "Copyright Crossway. Noncommercial API terms and required attribution apply. Not an unrestricted resource pack.",
              sourceURL: URL(string: "https://api.esv.org/")!),
        .init(id: "nkjv", title: "New King James Version", access: .ownAccount,
              detail: "Experimental online connection through your own eligible API.Bible account and key. Access depends on your plan, translation entitlement and the publisher’s terms.",
              rights: "Copyright Thomas Nelson. Current API.Bible terms govern caching, attribution and permitted use.",
              sourceURL: URL(string: "https://api.bible/terms-and-conditions")!),
        .init(id: "licensed-packs", title: "Licensed offline packs, including NASB", access: .ownAccount,
              detail: "NASB is a pack slot, not an included Bible or an online connection. Install a compatible pack only when you hold permission for that use.",
              rights: "A pack’s availability does not grant redistribution rights. ESV, NASB and NKJV text is not bundled.",
              sourceURL: URL(string: "https://www.lockman.org/permission-to-quote-copyright-trademark-information/")!),
        .init(id: "hcf", title: "Church Fathers extracts — mixed rights", access: .rightsReview,
              detail: "Present in this beta, but not cleared for unrestricted redistribution. The Historical Christian Faith database combines public-domain editions with excerpts from modern copyrighted translations. Review is needed per work and translation.",
              rights: "Upstream’s public-domain dedication covers its compilation and public-domain excerpts. Copyrighted excerpts retain their original rights; upstream’s fair-use position does not grant downstream distribution permission.",
              sourceURL: URL(string: "https://github.com/HistoricalChristianFaith/Commentaries-Database/blob/master/LICENSE")!)
    ]

    static func resources(in group: ResourceAccessGroup, includesHCF: Bool = true) -> [StudyResourceInfo] {
        resources.filter { $0.access == group }.map { resource in
            guard resource.id == "hcf", !includesHCF else { return resource }
            return StudyResourceInfo(id: resource.id, title: "Church Fathers extracts — withheld", access: .rightsReview,
                detail: "Not included in this build. The Historical Christian Faith database mixes public-domain editions with modern copyrighted translations. Its extracts are withheld until permission is verified per work and translation.",
                rights: resource.rights, sourceURL: resource.sourceURL)
        }
    }

    enum BibleAvailability: Equatable, Sendable {
        case included, installed, availableToDownload, unavailable

        var label: String {
            switch self {
            case .included: "Included offline"
            case .installed: "Installed offline"
            case .availableToDownload: "Available to download"
            case .unavailable: "Not available offline"
            }
        }
        var symbol: String {
            switch self {
            case .included, .installed: "checkmark.circle"
            case .availableToDownload: "arrow.down.circle"
            case .unavailable: "minus.circle"
            }
        }
    }

    /// Uses the current library scan, not filesystem guesses or a remembered download flag.
    static func availability(of id: String, in translations: [TranslationInfo]) -> BibleAvailability {
        let missing: BibleAvailability = BibleDownload.catalog.contains(where: { $0.id == id }) ? .availableToDownload : .unavailable
        guard let translation = translations.first(where: { $0.id == id }) else { return missing }
        switch translation.delivery {
        case .bundled: return .included
        case .installedPack: return .installed
        case .online, .licensePackRequired: return missing
        }
    }

    static var readingWorkCount: Int? {
        guard let url = AppResources.url("PuritanLibrary/catalog.json"),
              let data = try? Data(contentsOf: url),
              let catalogue = try? JSONDecoder().decode(PuritanLibraryCatalogue.self, from: data) else { return nil }
        return catalogue.works.count
    }
}
