//
//  BookPositionUseCase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 21/12/25.
//

import DCEpubReaderKit
import Foundation

protocol BookPositionUseCaseProtocol {
    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws
}

final class BookPositionUseCase: BookPositionUseCaseProtocol {

    private let repository: BookPositionRepositoryProtocol

    init(repository: BookPositionRepositoryProtocol) {
        self.repository = repository
    }

    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws {
        try repository.saveBookPosition(
            book: book,
            spineIndex: spineIndex,
            coords: coords,
            chapterURL: chapterURL,
            markType: markType
        )
    }
}
