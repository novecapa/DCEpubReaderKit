//
//  BookHighlightStore.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 04/05/26.
//

import DCEpubReaderKit
import Foundation

@MainActor
final class BookHighlightStore: DCHighlightStoreProtocol {

    private let useCase: BookHighlightUseCaseProtocol

    init(useCase: BookHighlightUseCaseProtocol) {
        self.useCase = useCase
    }

    func save(_ highlight: DCHighlight) async {
        try? useCase.saveHighlight(highlight)
    }

    func highlights(bookId: String) async -> [DCHighlight] {
        (try? useCase.highlights(bookId: bookId)) ?? []
    }

    func highlights(bookId: String, chapterId: String) async -> [DCHighlight] {
        (try? useCase.highlights(bookId: bookId, chapterId: chapterId)) ?? []
    }

    func delete(uuid: String) async {
        try? useCase.deleteHighlight(uuid: uuid)
    }
}
