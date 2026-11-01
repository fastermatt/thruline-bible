import XCTest
@testable import StudyTable

final class CollaborationBuildoutTests: XCTestCase {
    func testPortableFixtureAndAppExportAgree() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf: root.appendingPathComponent("collaboration/fixtures/suggestion.json"))
        let draft = try JSONDecoder().decode(ContributionDraft.self, from: data)
        XCTAssertNil(draft.validationMessage)
        XCTAssertEqual(draft.language, "Español")
        XCTAssertTrue(draft.details.contains("العربية"))
        let exported = try draft.encoded()
        XCTAssertEqual(try JSONDecoder().decode(ContributionDraft.self, from: exported), draft)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: exported) as? [String: Any])
        XCTAssertEqual(Set(object.keys), ["schemaVersion", "kind", "title", "resource", "reference", "language", "details", "sourceURL"])
    }
    func testDraftRejectsBlankAndCredentialLinks() {
        var draft = ContributionDraft()
        XCTAssertNotNil(draft.validationMessage)
        draft.title = "Reference correction"; draft.details = "Please check this passage."
        XCTAssertNil(draft.validationMessage)
        for link in ["file:///tmp/notes", "http://example.org", "https://user:password@example.org", "https://example.org/\nsecret"] {
            draft.sourceURL = link; XCTAssertNotNil(draft.validationMessage)
        }
        draft.sourceURL = "https://example.org/source"
        XCTAssertNil(draft.validationMessage)
        draft.details = String(repeating: "a", count: 20001)
        XCTAssertNotNil(draft.validationMessage)
    }
    func testDiscoveryHasRealRoutesWithoutPublisherOrWithheldEntries() {
        let catalog = DiscoverableResource.catalog
        XCTAssertEqual(Set(catalog.map(\.id)).count, catalog.count)
        XCTAssertFalse(catalog.contains { ["hcf", "esv", "nkjv", "licensed-packs"].contains($0.id) })
        for entry in catalog {
            switch entry.route {
            case .included(let id): XCTAssertTrue(ResourceCatalog.resources(in: .included).contains { $0.id == id })
            case .book(let id): XCTAssertTrue(OpenResource.catalog.contains { $0.id == id } || CommentaryPack.catalog.contains { $0.id == id } || HistoricWork.catalog.contains { $0.id == id })
            case .bible(let id): XCTAssertTrue(BibleDownload.catalog.contains { $0.id == id })
            case .historic: XCTAssertEqual(entry.id, "historic")
            }
        }
    }
    func testDiscoveryCombinesQueryLanguageAndType() {
        let catalog = DiscoverableResource.catalog
        XCTAssertEqual(DiscoverableResource.matching(catalog, query: "reina 1909", kind: .bible, language: "Español").map(\.id), ["RV1909"])
        XCTAssertEqual(DiscoverableResource.matching(catalog, query: "francais", kind: .bible, language: "All languages").map(\.id), ["FOB", "LSG"])
        XCTAssertTrue(DiscoverableResource.matching(catalog, query: "reina", kind: .notes, language: "All languages").isEmpty)
        XCTAssertEqual(DiscoverableResource.matching(catalog, query: " \n ", kind: .all, language: "All languages").count, catalog.count)
    }
    func testIvoryDefaultsAndClassicRemainDistinct() {
        XCTAssertNotEqual(WorkspacePalette.preset("Classic"), .standard)
        XCTAssertEqual(WorkspacePalette.preset("Ivory"), .standard)
        XCTAssertTrue(WorkspacePalette.standard.light.isValid)
        XCTAssertTrue(WorkspacePalette.standard.dark.isValid)
    }
}
