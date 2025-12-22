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
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws {}
}
