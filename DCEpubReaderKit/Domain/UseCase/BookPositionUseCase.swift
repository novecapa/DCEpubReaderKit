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
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws {}
}
