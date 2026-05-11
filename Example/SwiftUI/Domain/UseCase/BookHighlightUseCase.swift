//
//  BookHighlightUseCase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 04/05/26.
//

import DCEpubReaderKit
import Foundation

protocol BookHighlightUseCaseProtocol {
    func saveHighlight(_ highlight: DCHighlight) throws
    func highlights(bookId: String) throws -> [DCHighlight]
    func highlights(bookId: String, chapterId: String) throws -> [DCHighlight]
    func deleteHighlight(uuid: String) throws
}

final class BookHighlightUseCase: BookHighlightUseCaseProtocol {

    private let repository: BookHighlightRepositoryProtocol

    init(repository: BookHighlightRepositoryProtocol) {
        self.repository = repository
    }

    func saveHighlight(_ highlight: DCHighlight) throws {
        try repository.saveHighlight(highlight)
    }

    func highlights(bookId: String) throws -> [DCHighlight] {
        try repository.highlights(bookId: bookId)
    }

    func highlights(bookId: String, chapterId: String) throws -> [DCHighlight] {
        try repository.highlights(bookId: bookId, chapterId: chapterId)
    }

    func deleteHighlight(uuid: String) throws {
        try repository.deleteHighlight(uuid: uuid)
    }
}
