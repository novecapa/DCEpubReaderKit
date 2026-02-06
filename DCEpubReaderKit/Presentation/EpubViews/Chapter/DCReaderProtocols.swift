//
//  DCReaderProtocols.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/2/26.
//

import Foundation

protocol DCReaderCoordsProtocol {
    func handleCoords(book: EpubBook,
                      spineIndex: Int,
                      coords: String,
                      chapterURL: URL?,
                      isBookMark: Bool)
}
