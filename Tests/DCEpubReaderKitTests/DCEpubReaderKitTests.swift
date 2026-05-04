import XCTest
import DCEpubCore
import DCEpubParser

final class DCEpubReaderKitTests: XCTestCase {

    func testParserReadsMinimalEPUBFixture() throws {
        let rootURL = try fixtureURL(named: "MinimalEPUB")

        let book = try DCEpubParser.parse(from: rootURL)

        XCTAssertEqual(book.packagePath, "OEBPS/content.opf")
        XCTAssertEqual(book.metadata.title, "Minimal Test Book")
        XCTAssertEqual(book.metadata.creators, ["DCEpub Test Author"])
        XCTAssertEqual(book.metadata.language, "en")
        XCTAssertEqual(book.metadata.identifiers, ["urn:uuid:12345678-1234-1234-1234-123456789abc"])
        XCTAssertEqual(book.uniqueIdentifier, "12345678-1234-1234-1234-123456789abc")
        XCTAssertEqual(book.manifest.count, 3)
        XCTAssertEqual(book.spine.map(\.idref), ["chapter-one"])
        XCTAssertEqual(book.toc.first?.label, "Chapter One")
        XCTAssertEqual(book.chapterTitle(forSpineIndex: 0), "Chapter One")
        XCTAssertEqual(book.spineIndex(forTOCHref: "Text/chapter1.xhtml"), 0)
        XCTAssertEqual(book.chapterURL(forSpineIndex: 0)?.lastPathComponent, "chapter1.xhtml")
    }

    func testParserThrowsWhenContainerIsMissing() throws {
        let temporaryRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporaryRoot) }

        XCTAssertThrowsError(try DCEpubParser.parse(from: temporaryRoot)) { error in
            guard case DCEpubError.missingContainer = error else {
                return XCTFail("Expected missingContainer, got \(error)")
            }
        }
    }

    private func fixtureURL(named name: String) throws -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures") else {
            throw XCTSkip("Missing fixture directory: \(name)")
        }
        return url
    }
}
