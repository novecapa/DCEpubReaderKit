//
//  BookHighlightRepository.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 04/05/26.
//

import DCEpubReaderKit
import Foundation

protocol BookHighlightRepositoryProtocol {
    func saveHighlight(_ highlight: DCHighlight) throws
    func highlights(bookId: String, chapterId: String) throws -> [DCHighlight]
    func deleteHighlight(uuid: String) throws
}

final class BookHighlightRepository: BookHighlightRepositoryProtocol {

    private let database: BookHighlightDatabaseProtocol

    init(database: BookHighlightDatabaseProtocol) {
        self.database = database
    }

    func saveHighlight(_ highlight: DCHighlight) throws {
        try database.saveHighlight(highlight)
    }

    func highlights(bookId: String, chapterId: String) throws -> [DCHighlight] {
        try database.highlights(bookId: bookId, chapterId: chapterId)
    }

    func deleteHighlight(uuid: String) throws {
        try database.deleteHighlight(uuid: uuid)
    }
}
