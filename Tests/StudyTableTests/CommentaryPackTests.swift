import XCTest
import CryptoKit
@testable import StudyTable

final class CommentaryPackTests: XCTestCase {
    private static let repoRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private func committedPack(_ pack: CommentaryPack) throws -> Data {
        try Data(contentsOf: Self.repoRoot.appendingPathComponent("resource-packs/\(pack.id).json"))
    }
    private func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    func testCatalogPinsHostSizeAndHashOfTheCommittedPack() throws {
        XCTAssertFalse(CommentaryPack.catalog.isEmpty)
        XCTAssertEqual(Set(CommentaryPack.catalog.map(\.id)).count, CommentaryPack.catalog.count)
        for pack in CommentaryPack.catalog {
            XCTAssertEqual(pack.url.scheme, "https")
            XCTAssertEqual(pack.url.host, CommentaryPack.host)
            XCTAssertLessThanOrEqual(pack.bytes, CommentaryPack.maximumBytes)
            let data = try committedPack(pack)
            XCTAssertEqual(data.count, pack.bytes, "update the catalogue after rebuilding the pack")
            XCTAssertEqual(hash(data), pack.sha256, "update the catalogue after rebuilding the pack")
        }
    }

    func testCommittedPackInstallsAndAnchorsToPassages() throws {
        let pack = try XCTUnwrap(CommentaryPack.catalog.first { $0.id == "adam-clarke" })
        let book = try CommentaryPackFiles.convert(pack, data: try committedPack(pack))
        XCTAssertEqual(book.id, "adam-clarke")
        XCTAssertTrue(book.attribution.contains("AO Lab"))
        let hits = book.articles.filter { $0.anchor?.overlaps(Anchor(book: "GEN", chapter: 1, verse: 2)) == true }
        XCTAssertTrue(hits.contains { $0.id == "GEN.1.2" })
        XCTAssertFalse(book.articles.contains { $0.anchor?.book == "MAT" }, "Matthew is absent upstream and must stay disclosed, not invented")

        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        try ResourceBookFiles.store(book, root: root)
        let scan = try ResourceBookFiles.scan(root: root)
        XCTAssertEqual(scan.books.map(\.id), ["adam-clarke"])
        XCTAssertEqual(scan.unreadable, 0)
    }

    func testAlteredOrTruncatedDataIsRefused() throws {
        let pack = try XCTUnwrap(CommentaryPack.catalog.first)
        var flipped = try committedPack(pack)
        flipped[flipped.count / 2] ^= 0x01
        XCTAssertThrowsError(try CommentaryPackFiles.convert(pack, data: flipped))
        XCTAssertThrowsError(try CommentaryPackFiles.convert(pack, data: try committedPack(pack).prefix(100)))
        XCTAssertThrowsError(try CommentaryPackFiles.convert(pack, data: Data()))
    }

    func testAnchoredPacksAreNotRescannedForCitations() {
        for pack in CommentaryPack.catalog { XCTAssertTrue(LibraryCitationIndex.skippedBooks.contains(pack.id)) }
        XCTAssertTrue(DownloadedPassageNotes.anchoredBookIDs.contains("adam-clarke"))
    }

    func testDiscoveryListsPacksAsCommentariesNotIncluded() {
        let entries = DiscoverableResource.catalog.filter { $0.kind == .commentary }
        XCTAssertEqual(entries.map(\.id), CommentaryPack.catalog.map(\.id))
        XCTAssertTrue(entries.allSatisfy { !$0.included })
        XCTAssertTrue(ResourceCatalog.resources(in: .downloads).contains { $0.id == "commentary-packs" })
    }
}
