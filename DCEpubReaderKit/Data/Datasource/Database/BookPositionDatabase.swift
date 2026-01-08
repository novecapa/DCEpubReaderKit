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
                          chapterURL: URL) throws
}

final class BookPositionDatabase: BookPositionDatabaseProtocol {
    func saveLastPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL) throws {
        let realm = try Realm()
        // Update
        if let position = realm.objects(RBookMark.self).filter("uuid = '\(book.opfDirectoryURL)'").first {
            try realm.write {
                position.lastcoords = coords
                position.lastchapterid = chapterURL.lastPathComponent
            }
            // Create
        } else {
            // TODO: --
        }
    }
}
