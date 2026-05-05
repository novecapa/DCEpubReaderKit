//
//  DCReaderProtocols.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/2/26.
//

import Foundation
import DCEpubCore

public protocol DCReaderCoordsProtocol {
    func handleCoords(book: DCEpubBook,
                      spineIndex: Int,
                      coords: String,
                      chapterURL: URL?,
                      isBookMark: Bool)
}
