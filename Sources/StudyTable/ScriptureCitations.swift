import Foundation

/// A Bible reference found inside a book's own text, such as "Rom. viii. 28" or "John 3:16".
/// Detection is automatic and conservative: a book name or standard abbreviation followed by a
/// chapter (arabic or roman) and a verse, checked against the 66-book chapter table. Chapter-only
/// references ("Ps. li.") and verse lists after the first verse are not linked.
struct ScriptureCitation: Hashable, Sendable {
    /// UTF-16 range in the scanned text.
    let range: NSRange
    let anchor: Anchor
    let text: String
}

enum ScriptureReferenceScanner {
    // prefix? · capitalised book word · optional period · chapter · separator · verse · optional range
    nonisolated(unsafe) private static let pattern = try! NSRegularExpression(pattern:
        #"(?<![\p{L}\p{N}])((?:[123]|I{1,3}|1st|2nd|3rd|First|Second|Third)\s?)?([A-Z][a-z]{1,13})\.?\s+([ivxlc]{1,8}|[IVXLC]{1,8}|\d{1,3})(?:\s*[.:,]\s*|\s+)(\d{1,3})(?:\s*[-\u2013\u2014]\s*(\d{1,3}))?(?![\p{L}\d])"#)
    /// Common words that also abbreviate books; they must look like a reference, not prose.
    private static let proseWords: Set<String> = ["Is", "Am", "Ex", "So", "Re", "Ge", "La", "Ac", "Ho", "Ne", "Es", "Pe", "Pr", "Le", "Na", "Ob", "Da", "De", "Ch", "Co", "Ti", "Th", "Sa"]

    static func citations(in text: String) -> [ScriptureCitation] {
        let ns = text as NSString
        var found: [ScriptureCitation] = []
        pattern.enumerateMatches(in: text, range: NSRange(location: 0, length: ns.length)) { match, _, _ in
            guard let match, let citation = resolve(match, in: ns) else { return }
            found.append(citation)
        }
        return found
    }

    private static func group(_ match: NSTextCheckingResult, _ index: Int, _ text: NSString) -> String? {
        let range = match.range(at: index)
        return range.location == NSNotFound ? nil : text.substring(with: range)
    }

    private static func resolve(_ match: NSTextCheckingResult, in text: NSString) -> ScriptureCitation? {
        guard let word = group(match, 2, text), let chapterText = group(match, 3, text),
              let verseText = group(match, 4, text), let verse = Int(verseText), (1...200).contains(verse) else { return nil }
        let prefix = group(match, 1, text)?.trimmingCharacters(in: .whitespaces)
        // Bare two-letter words that are also English ("Is 3 4") need the abbreviation period.
        let whole = text.substring(with: match.range)
        if prefix == nil, proseWords.contains(word), !whole.contains(word + ".") { return nil }
        let token = [prefix, word].compactMap { $0 }.joined(separator: " ")
        guard let split = BookTable.splitReference(token + " 1"), split.remainder == "1" else { return nil }
        guard let chapter = Int(chapterText) ?? romanValue(chapterText), chapter >= 1, chapter <= split.book.chapters else { return nil }
        var end = verse
        if let endText = group(match, 5, text), let value = Int(endText), value > verse, value <= 200 { end = value }
        let anchor = Anchor(book: split.book.code, chapter: chapter, verses: verse, to: end)
        return ScriptureCitation(range: match.range, anchor: anchor, text: whole)
    }

    static func romanValue(_ text: String) -> Int? {
        let values: [Character: Int] = ["i": 1, "v": 5, "x": 10, "l": 50, "c": 100]
        let digits = text.lowercased().compactMap { values[$0] }
        guard digits.count == text.count, !digits.isEmpty else { return nil }
        var total = 0
        for (index, value) in digits.enumerated() {
            if index + 1 < digits.count, value < digits[index + 1] { total -= value } else { total += value }
        }
        // Reject non-canonical forms ("iiii", "vx") by round-tripping.
        return roman(total) == text.lowercased() ? total : nil
    }
    private static func roman(_ number: Int) -> String {
        guard number > 0, number < 400 else { return "" }
        let table: [(Int, String)] = [(100, "c"), (90, "xc"), (50, "l"), (40, "xl"), (10, "x"), (9, "ix"), (5, "v"), (4, "iv"), (1, "i")]
        var n = number, out = ""
        for (value, symbol) in table { while n >= value { out += symbol; n -= value } }
        return out
    }
}

extension ResourceArticle {
    /// A tidy title for lists and headers: single spaces, no leftover _emphasis_ markers.
    var displayTitle: String { ResourceArticle.tidy(title) }
    static func tidy(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
            .replacingOccurrences(of: "_", with: "").trimmingCharacters(in: .whitespaces)
    }
    /// Reading paragraphs, in order. Indices are stable for a given installed text.
    var paragraphs: [String] {
        body.components(separatedBy: "\n\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
}

/// Numbered notes in a book: where each note's text is, and which paragraphs carry its "[n]" marker.
/// Handles converted Gutenberg notes ("[12] Rom. v. 1.") and the included edition's
/// "Footnote 12:" labels. Notes may live in a separate Footnotes section.
struct FootnoteMap: Sendable {
    struct Location: Hashable, Comparable, Sendable {
        let article: Int
        let paragraph: Int
        static func < (a: Self, b: Self) -> Bool { (a.article, a.paragraph) < (b.article, b.paragraph) }
    }
    private(set) var notes: [String: Location] = [:]
    private(set) var markers: [String: [Location]] = [:]
    var isEmpty: Bool { notes.isEmpty }

    nonisolated(unsafe) private static let leading = try! NSRegularExpression(pattern: #"^\[(\d{1,4})\]"#)
    nonisolated(unsafe) private static let label = try! NSRegularExpression(pattern: #"^Footnote (\d{1,4}):$"#)
    nonisolated(unsafe) static let marker = try! NSRegularExpression(pattern: #"\[(\d{1,4})\]"#)
    nonisolated(unsafe) private static let numbered = try! NSRegularExpression(pattern: #"^(\d{1,4})\.\s"#)

    static func build(_ paragraphs: [[String]]) -> FootnoteMap {
        var map = FootnoteMap()
        for (a, article) in paragraphs.enumerated() {
            var pendingLabel: String?
            for (i, text) in article.enumerated() {
                let ns = text as NSString, all = NSRange(location: 0, length: ns.length)
                if let match = label.firstMatch(in: text, range: all) { pendingLabel = ns.substring(with: match.range(at: 1)); continue }
                if let number = pendingLabel { map.notes[number] = map.notes[number] ?? Location(article: a, paragraph: i); pendingLabel = nil; continue }
                if let match = leading.firstMatch(in: text, range: all) {
                    let number = ns.substring(with: match.range(at: 1))
                    map.notes[number] = map.notes[number] ?? Location(article: a, paragraph: i)
                    continue
                }
                marker.enumerateMatches(in: text, range: all) { match, _, _ in
                    guard let match else { return }
                    map.markers[ns.substring(with: match.range(at: 1)), default: []].append(Location(article: a, paragraph: i))
                }
            }
        }
        // Editions that print notes as "344. Cf. 1 Thess. iv. 17." beside "[344]" markers in the text.
        for (a, article) in paragraphs.enumerated() {
            for (i, text) in article.enumerated() where text.count < 600 {
                let ns = text as NSString
                guard let match = numbered.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)) else { continue }
                let number = ns.substring(with: match.range(at: 1))
                if map.notes[number] == nil, map.markers[number] != nil { map.notes[number] = Location(article: a, paragraph: i) }
            }
        }
        return map
    }

    /// The paragraph whose "[n]" marker refers to the note at `location` (nearest before it).
    func body(forNoteAt location: Location) -> (note: String, location: Location)? {
        guard let number = notes.first(where: { $0.value == location })?.key, let candidates = markers[number], !candidates.isEmpty else { return nil }
        return (number, candidates.last(where: { $0 <= location }) ?? candidates[0])
    }
    func noteLocation(_ number: String) -> Location? { notes[number] }
    /// "642. Rev. xx. 4." or "[12] Rom. v. 1." — a note that is only references.
    static func isBareNote(_ text: String) -> Bool {
        text.range(of: #"^(\[\d{1,4}\]|\d{1,4}\.)\s"#, options: .regularExpression) != nil
    }
    func bodyLocation(_ number: String, near location: Location) -> Location? {
        guard let candidates = markers[number], !candidates.isEmpty else { return nil }
        return candidates.last(where: { $0 <= location }) ?? candidates[0]
    }
}

/// One paragraph of an installed book that cites a passage.
struct LibraryCitation: Identifiable, Hashable, Sendable {
    let bookID: String
    let bookTitle: String
    let author: String
    let articleID: String
    let articleTitle: String
    let paragraph: Int
    let anchor: Anchor
    let reference: String
    /// Set when the reference is in a numbered note; `paragraph` is then the sentence carrying the note marker.
    var footnote: String? = nil
    var id: String { "\(bookID)|\(articleID)|\(paragraph)|\(anchor.book).\(anchor.chapterStart).\(anchor.verseStart)-\(anchor.verseEnd)" }
}

/// Which open book, section and paragraph a reader should show.
struct LibraryFocus: Identifiable, Equatable, Sendable {
    var id = UUID()
    let bookID: String
    let articleID: String
    var paragraph: Int? = nil
    var terms: [String] = []
}

/// Passage → citing paragraphs across installed books. Built off the main thread from the books
/// themselves; nothing is stored separately, so removing a book removes its citations.
struct LibraryCitationIndex: Sendable {
    static let empty = LibraryCitationIndex(byBibleBook: [:], books: 0)
    /// Passage-anchored downloads (Tyndale study notes, commentary packs) are not rescanned.
    static let skippedBooks: Set<String> = Set(["tyndale-notes"] + CommentaryPack.catalog.map(\.id))
    let byBibleBook: [String: [LibraryCitation]]
    let books: Int
    var count: Int { byBibleBook.values.reduce(0) { $0 + $1.count } }

    static func build(_ books: [ResourceBook]) throws -> Self {
        var index: [String: [LibraryCitation]] = [:]
        var scanned = 0
        for book in books where !skippedBooks.contains(book.id) {
            scanned += 1
            let paragraphs = book.articles.map(\.paragraphs)
            let notes = FootnoteMap.build(paragraphs)
            for (a, article) in book.articles.enumerated() {
                try Task.checkCancellation()
                // Indexes of texts list references without saying anything about them.
                if article.title.range(of: "index", options: .caseInsensitive) != nil { continue }
                for (number, paragraph) in paragraphs[a].enumerated() {
                    var seen = Set<Anchor>()
                    let here = FootnoteMap.Location(article: a, paragraph: number)
                    // A reference inside a note is shown with the sentence that cites the note.
                    let target = notes.body(forNoteAt: here)
                    let home = target.map { book.articles[$0.location.article] } ?? article
                    // A bare note that could not be traced to its sentence says nothing worth showing.
                    if target == nil, paragraph.count < 80, FootnoteMap.isBareNote(paragraph) { continue }
                    for citation in ScriptureReferenceScanner.citations(in: paragraph) where seen.insert(citation.anchor).inserted {
                        index[citation.anchor.book, default: []].append(LibraryCitation(bookID: book.id, bookTitle: book.title,
                            author: book.author, articleID: home.id, articleTitle: home.displayTitle, paragraph: target?.location.paragraph ?? number,
                            anchor: citation.anchor, reference: citation.text, footnote: target?.note))
                    }
                }
            }
        }
        return LibraryCitationIndex(byBibleBook: index, books: scanned)
    }

    /// Paragraphs citing any verse in `anchor`, one entry per paragraph, in library order.
    func citing(_ anchor: Anchor) -> [LibraryCitation] {
        var seen = Set<String>()
        return (byBibleBook[anchor.book] ?? []).filter { $0.anchor.overlaps(anchor) && seen.insert("\($0.bookID)|\($0.articleID)|\($0.paragraph)").inserted }
    }
}
