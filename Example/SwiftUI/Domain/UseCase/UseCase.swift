//
//  UseCase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/2/26.
//

import Foundation

protocol UseCaseProtocol {
    var bookFile: BookFileUseCaseProtocol { get }
    var bookPosition: BookPositionUseCaseProtocol { get }
}

final class UseCase {

    private let bookFileUseCase: BookFileUseCaseProtocol
    private let bookPositionUseCase: BookPositionUseCaseProtocol

    init() {
        let bookFileDatabase = BookFileDatabase()
        let bookFileRepository = BookFileRepository(database: bookFileDatabase)
        self.bookFileUseCase = BookFileUseCase(repository: bookFileRepository)

        let bookPositionDatabase = BookPositionDatabase()
        let bookPositionRepository = BookPositionRepository(database: bookPositionDatabase)
        self.bookPositionUseCase = BookPositionUseCase(repository: bookPositionRepository)
    }
}

extension UseCase: UseCaseProtocol {
    var bookFile: BookFileUseCaseProtocol {
        bookFileUseCase
    }

    var bookPosition: BookPositionUseCaseProtocol {
        bookPositionUseCase
    }
}
