//
//  BookFileDatabase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 19/1/26.
//

import Foundation
import RealmSwift

protocol BookFileDatabaseProtocol {
    func saveBook(book: EpubBook) throws
    func getBookList() throws -> [RBook]
    func getBook(uuid: String) throws -> RBook
    func deleteBook(uuid: String) throws
}

final class BookFileDatabase: BookFileDatabaseProtocol {
    func saveBook(book: EpubBook) throws {
        // TODO: --
    }
    
    func getBookList() throws -> [RBook] {
        // TODO: --
        []
    }
    
    func getBook(uuid: String) throws -> RBook {
        // TODO: --
        throw NSError(domain: "BookFileDatabase", code: 0, userInfo: nil)
    }
    
    func deleteBook(uuid: String) throws {
        // TODO: --
    }
}
