//
//  BookFileDatabase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 19/1/26.
//

import Foundation
import RealmSwift

protocol BookFileDatabaseProtocol {
    func saveBook(book: EpubBook) throws
    func getBookList() throws -> [RBook]
    func getBook(uuid: String) throws -> RBook
    func deleteBook(uuid: String) throws
}

final class BookFileDatabase: BookFileDatabaseProtocol {
    func saveBook(book: EpubBook) throws {
        let realm = try Realm()
        let nowMillis = Date().timeMillis
        let bookId = book.uniqueIdentifier
        let rootPath = book.resourcesRoot.path

        let record = RBook()
        record.uuid = bookId
        record.title = book.metadata.title ?? ""
        record.author = book.metadata.creators.first ?? ""
        record.path = rootPath
        record.coverPath = normalizeCoverPath(book.metadata.coverHint ?? "", basePath: rootPath)
        record.language = book.metadata.language ?? ""
        record.publisher = book.metadata.publisher ?? ""
        record.bookVersion = book.metadata.version ?? ""
        record.bookDate = book.metadata.date ?? ""
        record.descriptionHTML = book.metadata.descriptionHTML ?? ""
        record.updatedAt = nowMillis

        if let existing = realm.object(ofType: RBook.self, forPrimaryKey: bookId) {
            record.createdAt = existing.createdAt == 0 ? nowMillis : existing.createdAt
        } else {
            record.createdAt = nowMillis
        }

        try realm.write {
            realm.add(record, update: .modified)
        }
    }
    
    func getBookList() throws -> [RBook] {
        let realm = try Realm()
        let results = realm.objects(RBook.self).sorted(byKeyPath: "createdAt", ascending: false)
        try normalizeCoverPathsIfNeeded(results: results, realm: realm)
        return results.map { $0.detached() }
    }
    
    func getBook(uuid: String) throws -> RBook {
        let realm = try Realm()
        guard let book = realm.object(ofType: RBook.self, forPrimaryKey: uuid) else {
            throw RealmError.canNotLoadData(error: "Book not found for uuid: \(uuid)")
        }
        try normalizeCoverPathsIfNeeded(results: [book], realm: realm)
        return book.detached()
    }
    
    func deleteBook(uuid: String) throws {
        let realm = try Realm()
        guard let book = realm.object(ofType: RBook.self, forPrimaryKey: uuid) else {
            return
        }
        try realm.write {
            realm.delete(book)
        }
    }

    private func normalizeCoverPath(_ coverPath: String, basePath: String) -> String {
        guard !coverPath.isEmpty else { return "" }
        let normalizedBase = basePath.hasSuffix("/") ? basePath : basePath + "/"
        if coverPath.hasPrefix(normalizedBase) {
            let relative = String(coverPath.dropFirst(normalizedBase.count))
            return relative.isEmpty ? coverPath : relative
        }

        let bookId = URL(fileURLWithPath: basePath).lastPathComponent
        let token = "/\(bookId)/"
        if let range = coverPath.range(of: token) {
            let suffix = String(coverPath[range.upperBound...])
            if !suffix.isEmpty {
                return suffix
            }
        }

        return coverPath
    }

    private func normalizeCoverPathsIfNeeded<S: Sequence>(results: S, realm: Realm) throws where S.Element == RBook {
        var needsWrite = false
        for book in results {
            let normalized = normalizeCoverPath(book.coverPath, basePath: book.path)
            if normalized != book.coverPath {
                book.coverPath = normalized
                needsWrite = true
            }
        }
        if needsWrite {
            try realm.write {
                // Changes already applied to live objects
            }
        }
    }
}
