//
//  BookPositionDatabase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import Foundation
import RealmSwift

protocol BookPositionDatabaseProtocol {
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL)
}

final class BookPositionDatabase: BookPositionDatabaseProtocol {
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) {}
}
