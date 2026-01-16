//
//  BookPositionUseCase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 21/12/25.
//

import Foundation

protocol BookPositionUseCaseProtocol {
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws
}

final class BookPositionUseCase: BookPositionUseCaseProtocol {

    private let repository: BookPositionRepositoryProtocol

    init(repository: BookPositionRepositoryProtocol) {
        self.repository = repository
    }

    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws {
        try repository.saveLastPosition(book: book, spineIndex: spineIndex, coords: coords, chapterURL: chapterURL)
    }
}
