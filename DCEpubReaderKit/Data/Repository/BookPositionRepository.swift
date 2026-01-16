//
//  BookPositionRepository.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import Foundation

protocol BookPositionRepositoryProtocol {
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws
}

final class BookPositionRepository: BookPositionRepositoryProtocol {

    private let database: BookPositionDatabaseProtocol

    init(database: BookPositionDatabaseProtocol) {
        self.database = database
    }

    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws {
        try database.saveLastPosition(book: book, spineIndex: spineIndex, coords: coords, chapterURL: chapterURL)
    }
}
