//
//  BookFileRepository.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 19/1/26.
//

import DCEpubReader
import Foundation

protocol BookFileRepositoryProtocol {
    func saveBook(book: DCEpubBook) throws
    func getBookList() throws -> [EBookEntity]
    func getBook(uuid: String) throws -> EBookEntity
    func deleteBook(uuid: String) throws
}

final class BookFileRepository: BookFileRepositoryProtocol {

    private let database: BookFileDatabaseProtocol

    init(database: BookFileDatabaseProtocol) {
        self.database = database
    }

    func saveBook(book: DCEpubBook) throws {
        try database.saveBook(book: book)
    }

    func getBookList() throws -> [EBookEntity] {
        try database.getBookList().map { $0.toEntity }
    }

    func getBook(uuid: String) throws -> EBookEntity {
        try database.getBook(uuid: uuid).toEntity
    }

    func deleteBook(uuid: String) throws {
        try database.deleteBook(uuid: uuid)
    }
}

// MARK: - RBook converter

private extension RBook {
    var toEntity: EBookEntity {
        EBookEntity(
            uuid: self.uuid,
            title: self.title,
            author: self.author,
            coverPath: self.coverPath,
            language: self.language,
            publisher: self.publisher,
            bookVersion: self.bookVersion,
            bookDate: self.bookDate,
            descriptionHTML: self.descriptionHTML,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
