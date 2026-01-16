//
//  BookPositionDatabase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import Foundation
import RealmSwift

protocol BookPositionDatabaseProtocol {
    func saveBookPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws
}

final class BookPositionDatabase: BookPositionDatabaseProtocol {
    func saveBookPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws {
        let realm = try Realm()
        switch markType {
        case .lastPosition:
            if let mark = realm.objects(RBookMark.self).filter("uuid = '\(book.uniqueIdentifier)' AND type = '\(markType.rawValue)'").first {
                try realm.write {
                    mark.type = markType.rawValue
                    mark.bookTitle = book.bookTitle
                    mark.lastcoords = coords
                    mark.lastchapterid = chapterURL.lastPathComponent
                    mark.dateUpdated = NSDate().timeIntervalSince1970 * 1000
                }
            } else {
                let mark = RBookMark()
                mark.type = markType.rawValue
                mark.uuid = "\(book.uniqueIdentifier)"
                mark.compoundKey = mark.compound
                mark.bookTitle = book.bookTitle
                mark.lastcoords = coords
                mark.lastchapterid = chapterURL.lastPathComponent
                mark.dateCreated = NSDate().timeIntervalSince1970 * 1000
                try realm.write {
                    realm.add(mark, update: .modified)
                }
            }
        case .bookMark:
            let mark = RBookMark()
            mark.type = markType.rawValue
            mark.uuid = "\(book.uniqueIdentifier)"
            mark.compoundKey = mark.compound
            mark.bookTitle = book.bookTitle
            mark.coords = coords
            mark.chapterId = chapterURL.lastPathComponent
            mark.dateCreated = NSDate().timeIntervalSince1970 * 1000
            try realm.write {
                realm.add(mark, update: .modified)
            }
        default:
            break
        }
    }
}

final class BookPositionDatabaseMock: BookPositionDatabaseProtocol {
    func saveBookPosition(book: EpubBook,
                          spineIndex: Int,
                          coords: String,
                          chapterURL: URL,
                          markType: RBookMark.MarkType) throws {}
}
