//
//  BookPositionRepository.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import DCEpubReaderKit
import Foundation

protocol BookPositionRepositoryProtocol {
    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws
}

final class BookPositionRepository: BookPositionRepositoryProtocol {

    private let database: BookPositionDatabaseProtocol

    init(database: BookPositionDatabaseProtocol) {
        self.database = database
    }

    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws {
        try database.saveBookPosition(
            book: book,
            spineIndex: spineIndex,
            coords: coords,
            chapterURL: chapterURL,
            markType: markType
        )
    }
}
