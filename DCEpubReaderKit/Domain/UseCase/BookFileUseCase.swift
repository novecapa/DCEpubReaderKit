//
//  BookFileUseCase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 19/1/26.
//

import DCEpubReader
import Foundation

protocol BookFileUseCaseProtocol {
    func saveBook(book: DCEpubBook) throws
    func getBookList() throws -> [EBookEntity]
    func getBook(uuid: String) throws -> EBookEntity
    func deleteBook(uuid: String) throws
}

final class BookFileUseCase: BookFileUseCaseProtocol {

    private let repository: BookFileRepositoryProtocol

    init(repository: BookFileRepositoryProtocol) {
        self.repository = repository
    }

    func saveBook(book: DCEpubBook) throws {
        try repository.saveBook(book: book)
    }
    
    func getBookList() throws -> [EBookEntity] {
        try repository.getBookList()
    }
    
    func getBook(uuid: String) throws -> EBookEntity {
        try repository.getBook(uuid: uuid)
    }
    
    func deleteBook(uuid: String) throws {
        try repository.deleteBook(uuid: uuid)
    }
}
