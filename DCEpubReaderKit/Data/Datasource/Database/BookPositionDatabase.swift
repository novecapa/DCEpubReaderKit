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
        if let mark = realm.objects(RBookMark.self).filter("uuid = '\(book.uniqueIdentifier)'").first {
            try realm.write {
                mark.type = RBookMark.MarkType.lastPosition.rawValue
                mark.bookTitle = book.bookTitle
                mark.lastcoords = coords
                mark.lastchapterid = chapterURL.lastPathComponent
                mark.dateUpdated = NSDate().timeIntervalSince1970 * 1000
            }
        } else {
            let mark = RBookMark()
            mark.type = RBookMark.MarkType.lastPosition.rawValue
            mark.uuid = "\(book.uniqueIdentifier)"
            mark.lastcoords = coords
            mark.lastchapterid = chapterURL.lastPathComponent
            mark.dateCreated = NSDate().timeIntervalSince1970 * 1000
            try realm.write {
                realm.add(mark, update: .modified)
            }
        }
    }
}

final class BookPositionDatabaseMock: BookPositionDatabaseProtocol {
    func saveLastPosition(book: EpubBook, spineIndex: Int, coords: String, chapterURL: URL) throws {}
}
