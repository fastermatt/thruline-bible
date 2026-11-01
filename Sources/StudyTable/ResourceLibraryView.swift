import SwiftUI
import UniformTypeIdentifiers

enum LibraryDestination: String, CaseIterable, Identifiable {
    case discover = "Discover", contribute = "Help improve Thruline", fathers = "Fathers & reception"
    case books = "My books", included = "Included study tools", modern = "Free study resources"
    case bibles = "Free Bibles", historic = "Historic works", publishers = "Publisher stores"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .discover: "magnifyingglass"
        case .contribute: "person.2"
        case .fathers: "building.columns.fill"
        case .books: "books.vertical"
        case .included: "text.book.closed"
        case .modern: "text.badge.plus"
        case .bibles: "book"
        case .historic: "building.columns"
        case .publishers: "arrow.up.right.square"
        }
    }
}

struct ResourceLibraryView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var books: ResourceBookLibrary
    @ObservedObject private var appearance = AppearanceUpdates.shared
    @StateObject private var historic: PuritanLibraryService
    @StateObject private var bibleDownloads = BibleDownloadManager()
    @State private var contributionDraft = ContributionDraft()
    @State private var destination: LibraryDestination
    @State private var importing = false
    @State private var selectedBook: ResourceBook?
    @State private var readerFocus: LibraryFocus?
    @State private var fathersSection: PatristicLibraryView.Section = .read
    @State private var query = ""
    @State private var fileError: String?
    init(books: ResourceBookLibrary, adding: Bool = false, destination: LibraryDestination? = nil, historic: PuritanLibraryService? = nil) {
        self.books = books
        _destination = State(initialValue: destination ?? (adding ? .discover : .books))
        _historic = StateObject(wrappedValue: historic ?? PuritanLibraryService())
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Library").font(.title2.weight(.semibold))
                Spacer()
                Button { importing = true } label: { Label("Import a book…", systemImage: "square.and.arrow.down") }
                    .disabled(books.activeID != nil)
            }.padding(20)
            Divider()
            HSplitView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach([LibraryDestination.discover, .books, .fathers, .included, .modern, .bibles, .historic, .publishers], id: \.self) { item in
                        destinationButton(item)
                    }
                    Spacer()
                    Divider().padding(.vertical, 10)
                    destinationButton(.contribute)
                    Text("Study freely. Build together.")
                        .font(.caption).foregroundStyle(STColor.secondary).padding(10)
                }.padding(12).frame(minWidth: 195, idealWidth: 210, maxWidth: 240)
                    .background(STColor.tileBottom)
                Group {
                    if let selectedBook {
                        ResourceBookReader(book: selectedBook, focus: readerFocus) { self.selectedBook = nil; readerFocus = nil }
                            .id(selectedBook.id + (readerFocus?.id.uuidString ?? ""))
                    } else {
                        detail
                    }
                }.frame(minWidth: 470, maxWidth: .infinity, maxHeight: .infinity)
            }
            if let message = books.message ?? fileError {
                Divider()
                HStack { Text(message).font(.callout); Spacer() }.padding(12).accessibilityAddTraits(.updatesFrequently)
            }
        }
        .foregroundStyle(STColor.ink).background(STColor.paper).tint(STColor.navy)
        .defaultAppStorage(state.preferenceStore)
        .frame(minWidth: 760, minHeight: 560)
        .task { await books.load() }
        .onChange(of: destination) { _, _ in selectedBook = nil; readerFocus = nil; query = "" }
        .onAppear { consumeLibraryRequest(); consumeDestinationRequest() }
        .onChange(of: state.libraryRequest) { _, _ in consumeLibraryRequest() }
        .onChange(of: state.libraryDestinationRequest) { _, _ in consumeDestinationRequest() }
        .onChange(of: books.books.count) { _, _ in consumeLibraryRequest() }
        .fileImporter(isPresented: $importing, allowedContentTypes: [UTType(filenameExtension: "epub")!, .plainText]) { result in
            switch result {
            case .success(let url): fileError = nil; books.importBook(url); destination = .books
            case .failure: fileError = "The file could not be opened. Please choose it again."
            }
        }
    }
    @ViewBuilder private var detail: some View {
        switch destination {
        case .discover:
            ResourceDiscoveryView(books: books, downloads: bibleDownloads, read: { selectedBook = $0 }, browseHistoric: { destination = .historic }, browseFathers: { destination = .fathers })
        case .fathers:
            PatristicLibraryView(initialSection: fathersSection, books: books, read: { selectedBook = $0 }).id(fathersSection)
        case .contribute:
            ContributionView(draft: $contributionDraft)
        case .books:
            VStack(alignment: .leading, spacing: 12) {
                Text("Your books & articles").font(.title2)
                Text("Read downloaded study resources and personal books. Use Included study tools for the built-in commentaries, dictionaries and language tools.")
                    .font(.callout).foregroundStyle(.secondary)
                TextField("Find a title or author", text: $query).textFieldStyle(.roundedBorder)
                if books.books.isEmpty {
                    ContentUnavailableView {
                        Label("Make this library yours", systemImage: "books.vertical")
                    } description: {
                        Text("Add free study notes and dictionaries, or import an EPUB or text file you own.")
                    } actions: { Button("Explore free resources") { destination = .discover } }
                } else {
                    List(books.books.filter { query.isEmpty || ($0.title + " " + $0.author).localizedCaseInsensitiveContains(query) }.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }) { book in
                        Button { selectedBook = book } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(book.title).font(.headline)
                                Text("\(book.author) · \(book.articles.count.formatted()) sections · Offline").font(.caption).foregroundStyle(.secondary)
                            }.padding(.vertical, 8).frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }.listStyle(.plain)
                }
            }.padding(22)
        case .included:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Ready for study").font(.title2)
                    Text("These resources are already available offline. Tools open beside your current Bible passage.").foregroundStyle(.secondary)
                    ForEach(ResourceCatalog.resources(in: .included)) { resource in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(resource.title).font(.headline)
                            Text(resource.detail).font(.callout)
                            HStack {
                                Button("Open in workspace") { openIncluded(resource.id) }
                                Link("Source & terms", destination: resource.sourceURL)
                            }.font(.callout)
                        }
                        Divider()
                    }
                }.padding(24)
            }
        case .modern:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Free study resources").font(.title2)
                    Text("Add once, then read and search offline. No account or developer key required.").foregroundStyle(.secondary)
                    ForEach(OpenResource.catalog) { resource in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(resource.title).font(.headline)
                            Text(resource.detail).font(.callout)
                            Text("Tyndale House Publishers · CC BY-SA 4.0 · English").font(.caption).foregroundStyle(.secondary)
                            HStack {
                                if let installed = books.books.first(where: { $0.id == resource.id }) {
                                    Label("Installed", systemImage: "checkmark.circle")
                                    Button("Read") { selectedBook = installed }
                                } else if books.activeID == resource.id {
                                    ProgressView().controlSize(.small)
                                    Text("Downloading & preparing…")
                                    Button("Cancel") { books.cancel() }
                                } else {
                                    Button("Add to library") { books.install(resource) }.disabled(books.activeID != nil)
                                }
                                Spacer()
                                Link("Source & license", destination: URL(string: "https://tyndaleopenresources.com/")!)
                            }.font(.callout)
                        }.padding(.vertical, 10)
                        Divider()
                    }
                    ForEach(CommentaryPack.catalog) { pack in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(pack.title).font(.headline)
                            Text(pack.detail).font(.callout)
                            Text(pack.terms).font(.caption).foregroundStyle(.secondary)
                            HStack {
                                if let installed = books.books.first(where: { $0.id == pack.id }) {
                                    Label("Installed", systemImage: "checkmark.circle")
                                    Button("Read") { selectedBook = installed }
                                } else if books.activeID == pack.id {
                                    ProgressView().controlSize(.small)
                                    Text("Downloading & preparing…")
                                    Button("Cancel") { books.cancel() }
                                } else {
                                    Button("Add to library") { books.install(pack) }.disabled(books.activeID != nil)
                                }
                                Spacer()
                                Link("Source & license", destination: pack.sourceURL)
                            }.font(.callout)
                        }.padding(.vertical, 10)
                        Divider()
                    }
                    Text("Classic Christian works").font(.title3).padding(.top, 6)
                    Text("Optional public-domain editions from Project Gutenberg. More early writers are under Fathers & reception.")
                        .font(.callout).foregroundStyle(.secondary)
                    ForEach(HistoricWork.works(on: .classics)) { work in
                        HistoricWorkRow(books: books, work: work, read: { selectedBook = $0 })
                        Divider()
                    }
                    Button("Browse Church Fathers") { destination = .fathers }
                    Button("Browse historic works") { destination = .historic }
                    Button("Find more Bible translations") { destination = .bibles }
                }.padding(24)
            }
        case .bibles:
            ScrollView { DownloadLibraryView(manager: bibleDownloads).padding(24) }
        case .historic:
            PuritanLibraryView(service: historic)
        case .publishers:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Bring your own books").font(.title2)
                    Text("Open a publisher’s store, buy an edition with an unencrypted EPUB download, then choose Import a book. Checkout and payment happen on the publisher’s website.")
                    Link("Browse The Good Book Company ebooks ↗", destination: URL(string: "https://www.thegoodbook.com/ebooks/")!)
                    Link("Read their ebook download instructions ↗", destination: URL(string: "https://www.thegoodbook.com/ebook-faq")!).font(.callout)
                    Divider()
                    Link("Browse Crossway ↗", destination: URL(string: "https://www.crossway.org/books/")!)
                    Link("Check Crossway ebook formats ↗", destination: URL(string: "https://www.crossway.org/faq/")!).font(.callout)
                    Text("Check the product’s format before buying. Thruline imports unencrypted EPUB and UTF-8 text; it cannot unlock Logos, Kindle or other DRM-protected libraries. Text imports omit images, original page numbers and publisher styling.")
                        .font(.callout).foregroundStyle(.secondary)
                    Button("Import a downloaded book…") { importing = true }.disabled(books.activeID != nil)
                    Divider()
                    Text("A complete free study workflow remains available. Buying books is optional.").font(.callout)
                }.padding(24)
            }
        }
    }
    private func destinationButton(_ item: LibraryDestination) -> some View {
        let selected = destination == item
        return Button { destination = item } label: {
            HStack(spacing: 10) {
                Image(systemName: item.symbol).frame(width: 18)
                Text(item.rawValue).font(.system(size: 13, weight: selected ? .semibold : .regular))
                Spacer(minLength: 0)
                if selected { Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold)) }
            }.foregroundStyle(selected ? STColor.navy : STColor.ink)
                .padding(.horizontal, 10).padding(.vertical, 11).contentShape(Rectangle())
                .background(selected ? STColor.tileWell : .clear, in: RoundedRectangle(cornerRadius: 4))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private func consumeDestinationRequest() {
        guard let request = state.libraryDestinationRequest else { return }
        if request == .fathers { fathersSection = .ideas }
        destination = request; selectedBook = nil
        state.libraryDestinationRequest = nil
    }

    /// Opens the reader at a section and paragraph requested elsewhere (Study Desk, search).
    private func consumeLibraryRequest() {
        guard let request = state.libraryRequest, let book = books.book(id: request.bookID) else { return }
        readerFocus = request
        selectedBook = book
        state.libraryRequest = nil
    }

    private func openIncluded(_ id: String) {
        if id == "apostolic-fathers" { destination = .fathers; return }
        state.revealIncludedResource(id)
        openWindow(id: "workspace")
    }

}

struct DownloadedPassageNotes: View {
    @ObservedObject var books: ResourceBookLibrary
    let anchor: Anchor?
    /// Installed downloads whose articles are anchored to passages.
    static let anchoredBookIDs = ["tyndale-notes"] + CommentaryPack.catalog.map(\.id)
    var body: some View {
        if let anchor {
            ForEach(Self.anchoredBookIDs, id: \.self) { id in
                if let book = books.books.first(where: { $0.id == id }) {
                    PassageNotesGroup(book: book, anchor: anchor)
                }
            }
        }
    }
}

private struct PassageNotesGroup: View {
    let book: ResourceBook
    let anchor: Anchor
    @State private var expanded = false
    private var label: String { book.id == "tyndale-notes" ? "Tyndale study notes" : book.title }
    var body: some View {
        let matches = book.articles.filter { $0.anchor?.overlaps(anchor) == true }
        if !matches.isEmpty {
            DisclosureGroup("\(label) · \(matches.count)", isExpanded: $expanded) {
                ForEach(matches) { article in
                    DisclosureGroup(article.title) {
                        Text(article.body).font(.system(size: 14, design: .serif)).lineSpacing(4).textSelection(.enabled)
                            .padding(.vertical, 8)
                    }.font(.callout).padding(.vertical, 4)
                }
                Text(book.attribution).font(.caption).foregroundStyle(.secondary)
            }.font(.headline).padding(14)
        }
    }
}


extension AppState {
    func revealIncludedResource(_ id: String) {
        focusMode = false; showStudyDesk = true; requestedStudyTool = nil
        if id == "commentaries" { deskMode = .sources }
        else if id == "cross-references" {
            selectedTraditions.insert(.crossReferences)
            deskMode = .sources
        } else {
            let sections: [String: StudyDeskSection] = ["scripture": .compare, "word-study": .originalLanguage, "passage-guide": .dictionary, "standards": .proofTexts]
            if let section = sections[id] { setDeskSectionVisible(section, true); requestedStudyTool = section }
            deskMode = .tools
        }
    }
}
