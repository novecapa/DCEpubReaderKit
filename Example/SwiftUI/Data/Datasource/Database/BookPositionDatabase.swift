//
//  BookPositionDatabase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import DCEpubReaderKit
import Foundation
import RealmSwift

protocol BookPositionDatabaseProtocol {
    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws
    // TODO: Get book position
}

final class BookPositionDatabase: BookPositionDatabaseProtocol {
    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws {
        let realm = try Realm()
        let nowMillis = Date().timeMillis
        switch markType {
        case .lastPosition:
            if let mark = realm.objects(RBookMark.self).filter(
                """
                uuid = '\(book.uniqueIdentifier)' AND
                type = '\(markType.rawValue)'
                """).first {
                try realm.write {
                    mark.type = markType.rawValue
                    mark.bookTitle = book.bookTitle
                    mark.lastcoords = coords
                    mark.lastchapterid = chapterURL.lastPathComponent
                    mark.dateUpdated = nowMillis
                }
            } else {
                let mark = RBookMark()
                mark.type = markType.rawValue
                mark.uuid = book.uniqueIdentifier
                mark.bookTitle = book.bookTitle
                mark.lastcoords = coords
                mark.lastchapterid = chapterURL.lastPathComponent
                mark.dateCreated = nowMillis
                mark.compoundKey = mark.compoundLastPosition
                try realm.write {
                    realm.add(mark, update: .modified)
                }
            }
        case .bookMark:
            let mark = RBookMark()
            mark.type = markType.rawValue
            mark.uuid = book.uniqueIdentifier
            mark.coords = coords
            mark.bookTitle = book.bookTitle
            mark.chapterId = chapterURL.lastPathComponent
            mark.dateCreated = nowMillis
            mark.compoundKey = mark.compoundBookmark
            try realm.write {
                realm.add(mark, update: .modified)
            }
        default:
            break
        }
    }
}

final class BookPositionDatabaseMock: BookPositionDatabaseProtocol {
    func saveBookPosition(book: DCEpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws {}
}
