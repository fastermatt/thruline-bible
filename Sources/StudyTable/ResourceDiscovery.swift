import SwiftUI

/// A discoverable route, not a second download catalogue. Actions resolve existing IDs.
struct DiscoverableResource: Identifiable, Sendable {
    enum Kind: String, CaseIterable { case all = "All resources", bible = "Bibles", study = "Study tools", commentary = "Commentaries", notes = "Notes & dictionaries", historic = "Historic works" }
    enum Route: Sendable { case included(String), book(String), bible(String), historic }
    let id: String
    let title: String
    let detail: String
    let language: String
    let kind: Kind
    let included: Bool
    let route: Route
    let terms: String
    let source: URL

    /// Optional commentary packs. Kept apart from `baseCatalog` so neither array expression grows too complex to type-check.
    private static var commentaryEntries: [Self] {
        CommentaryPack.catalog.map {
            Self(id: $0.id, title: $0.title, detail: $0.detail, language: "English", kind: .commentary,
                 included: false, route: .book($0.id), terms: $0.terms, source: $0.sourceURL)
        }
    }

    static var catalog: [Self] { baseCatalog + commentaryEntries }

    private static var baseCatalog: [Self] {
        ResourceCatalog.resources(in: .included).map {
            Self(id: $0.id, title: $0.title, detail: $0.detail, language: "English", kind: $0.id == "scripture" ? .bible : .study,
                 included: true, route: .included($0.id), terms: $0.rights, source: $0.sourceURL)
        } + OpenResource.catalog.map {
            Self(id: $0.id, title: $0.title, detail: $0.detail, language: "English", kind: .notes,
                 included: false, route: .book($0.id), terms: "Tyndale House Publishers · CC BY-SA 4.0. Attributed text adaptation; illustrations omitted.", source: URL(string: "https://tyndaleopenresources.com/")!)
        } + BibleDownload.catalog.map {
            Self(id: $0.id, title: $0.name, detail: $0.id == "DBY" ? DarbyComparisonContext.discovery : "Read, search and compare offline after downloading. Text only; verse numbering can differ.", language: $0.language,
                 kind: .bible, included: false, route: .bible($0.id), terms: $0.license, source: $0.sourceURL)
        } + HistoricWork.catalog.map {
            Self(id: $0.id, title: "\($0.title) — \($0.author)", detail: $0.detail + " " + $0.edition + ".", language: "English",
                 kind: .historic, included: false, route: .book($0.id),
                 terms: "Project Gutenberg eBook #\($0.ebook): public domain in the USA; laws elsewhere may differ. Converted to text on this Mac; inclusion is not doctrinal endorsement.", source: $0.page)
        } + [Self(id: "historic", title: "Historic works", detail: "Browse the Text Creation Partnership collection by author and work. Downloads have their own reader and table of contents; they are not linked by verse.", language: "English", kind: .historic, included: false, route: .historic,
                 terms: "Text Creation Partnership transcriptions: public domain. Catalogue: CC0. Facsimile images are not included.", source: URL(string: "https://www.textpartnership.net/pages/faq.html")!)]
    }

    static func matching(_ entries: [Self], query: String, kind: Kind, language: String) -> [Self] {
        let words = query.split(whereSeparator: \.isWhitespace).map(String.init)
        return entries.filter { entry in
            (kind == .all || entry.kind == kind) && (language == "All languages" || entry.language == language) &&
            words.allSatisfy { (entry.title + " " + entry.detail + " " + entry.language + " " + entry.id).localizedStandardContains($0) }
        }
    }
}

struct ResourceDiscoveryView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var books: ResourceBookLibrary
    @ObservedObject var downloads: BibleDownloadManager
    let read: (ResourceBook) -> Void
    let browseHistoric: () -> Void
    let browseFathers: () -> Void
    @State private var query = ""
    @State private var kind = DiscoverableResource.Kind.all
    @State private var language = "All languages"
    @State private var expanded: Set<String> = []
    private let entries = DiscoverableResource.catalog.filter { !$0.included } + DiscoverableResource.catalog.filter { $0.included }
    private var results: [DiscoverableResource] { DiscoverableResource.matching(entries, query: query, kind: kind, language: language) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Find your next study resource").font(.system(size: 25, weight: .regular))
                Text("Start with what’s included. Add more when you need it.")
                    .font(.callout).foregroundStyle(STColor.secondary)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(STColor.secondary)
                    TextField("Search resource titles, descriptions or languages", text: $query).textFieldStyle(.plain)
                    if !query.isEmpty { Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }.buttonStyle(.plain).accessibilityLabel("Clear resource search") }
                }.padding(10).background(STColor.tileWell, in: RoundedRectangle(cornerRadius: 4))
                HStack {
                    Picker("Type", selection: $kind) { ForEach(DiscoverableResource.Kind.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.frame(maxWidth: 230)
                    Picker("Language", selection: $language) {
                        Text("All languages").tag("All languages")
                        ForEach(Set(entries.map(\.language)).sorted(), id: \.self) { Text($0).tag($0) }
                    }.frame(maxWidth: 220)
                    Spacer(minLength: 0)
                }.font(.callout)
                Text("\(results.count) resource groups and editions").font(.caption).foregroundStyle(STColor.secondary)
            }.padding(24)
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if results.isEmpty {
                        ContentUnavailableView {
                            Label("No matching resources", systemImage: "magnifyingglass")
                        } description: { Text("Try another title or clear your filters. This searches the catalogue, not the books’ full text.") }
                        actions: { Button("Clear search and filters") { query = ""; kind = .all; language = "All languages" } }
                    }
                    ForEach(results) { entry in resourceRow(entry); Divider() }
                }.padding(.horizontal, 24)
            }
            if let message = downloads.message {
                Text(message).font(.callout).padding(12).accessibilityAddTraits(.updatesFrequently)
            }
        }.background(STColor.paper)
    }

    private func resourceRow(_ entry: DiscoverableResource) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.title).font(.system(size: 16, weight: .medium))
                    Text(entry.language + " · " + (entry.included ? "Included offline" : "Free download"))
                        .font(.caption).foregroundStyle(STColor.secondary)
                }
                Spacer(minLength: 4)
                action(entry).controlSize(.regular).fixedSize()
            }
            Text(entry.detail).font(.callout).foregroundStyle(STColor.secondary).fixedSize(horizontal: false, vertical: true)
            DarbyComparisonNotice(translationID: entry.id)
            DisclosureGroup("Source & permissions", isExpanded: Binding(get: { expanded.contains(entry.id) }, set: { if $0 { expanded.insert(entry.id) } else { expanded.remove(entry.id) } })) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.terms).textSelection(.enabled)
                    Link("View original source", destination: entry.source)
                }.font(.caption).padding(.top, 6)
            }.font(.caption).tint(STColor.secondary)
        }.padding(.vertical, 20)
    }

    @ViewBuilder private func action(_ entry: DiscoverableResource) -> some View {
        switch entry.route {
        case .included(let id):
            Button("Open") {
                if id == "apostolic-fathers" { browseFathers() }
                else { state.revealIncludedResource(id); openWindow(id: "workspace") }
            }
                .accessibilityLabel("Open \(entry.title)")
        case .book(let id):
            if let book = books.books.first(where: { $0.id == id }) {
                Button { read(book) } label: { Label("Read", systemImage: "checkmark") }
            } else if books.activeID == id {
                HStack { ProgressView().controlSize(.small); Button("Cancel") { books.cancel() } }
            } else if let resource = OpenResource.catalog.first(where: { $0.id == id }) {
                Button { books.install(resource) } label: { Label("Add", systemImage: "plus") }.disabled(books.activeID != nil)
                    .accessibilityLabel("Add \(entry.title)")
            } else if let pack = CommentaryPack.catalog.first(where: { $0.id == id }) {
                Button { books.install(pack) } label: { Label("Add", systemImage: "plus") }.disabled(books.activeID != nil)
                    .accessibilityLabel("Add \(entry.title)")
            } else if let work = HistoricWork.catalog.first(where: { $0.id == id }) {
                Button { books.install(work) } label: { Label("Add", systemImage: "plus") }.disabled(books.activeID != nil)
                    .accessibilityLabel("Add \(entry.title)")
            }
        case .bible(let id):
            if downloads.activeID == id {
                HStack { ProgressView(value: downloads.progress).frame(width: 45); Button("Cancel") { downloads.cancel() } }
            } else if state.library.translation(id: id)?.isOffline == true {
                Button { state.translationID = id; openWindow(id: "workspace") } label: { Label("Read", systemImage: "checkmark") }
            } else if let edition = BibleDownload.catalog.first(where: { $0.id == id }) {
                Button { downloads.download(edition, root: state.library.userPackDirectory) { state.rescanTranslations() } } label: { Label("Add", systemImage: "plus") }
                    .disabled(downloads.activeID != nil).accessibilityLabel("Add \(entry.title)")
            }
        case .historic: Button("Browse", action: browseHistoric)
        }
    }
}
