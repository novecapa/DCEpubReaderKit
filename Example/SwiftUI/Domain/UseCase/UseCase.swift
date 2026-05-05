//
//  UseCase.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/2/26.
//

import DCEpubReaderKit
import Foundation

protocol UseCaseProtocol {
    var bookFile: BookFileUseCaseProtocol { get }
    var bookPosition: BookPositionUseCaseProtocol { get }
    var bookHighlight: BookHighlightUseCaseProtocol { get }
    @MainActor var highlightStore: any DCHighlightStoreProtocol { get }
}

final class UseCase {

    private let bookFileUseCase: BookFileUseCaseProtocol
    private let bookPositionUseCase: BookPositionUseCaseProtocol
    private let bookHighlightUseCase: BookHighlightUseCaseProtocol
    @MainActor private let _highlightStore: BookHighlightStore

    @MainActor
    init() {
        let bookFileDatabase = BookFileDatabase()
        let bookFileRepository = BookFileRepository(database: bookFileDatabase)
        self.bookFileUseCase = BookFileUseCase(repository: bookFileRepository)

        let bookPositionDatabase = BookPositionDatabase()
        let bookPositionRepository = BookPositionRepository(database: bookPositionDatabase)
        self.bookPositionUseCase = BookPositionUseCase(repository: bookPositionRepository)

        let bookHighlightDatabase = BookHighlightDatabase()
        let bookHighlightRepository = BookHighlightRepository(database: bookHighlightDatabase)
        self.bookHighlightUseCase = BookHighlightUseCase(repository: bookHighlightRepository)
        self._highlightStore = BookHighlightStore(useCase: bookHighlightUseCase)
    }
}

extension UseCase: UseCaseProtocol {
    var bookFile: BookFileUseCaseProtocol { bookFileUseCase }
    var bookPosition: BookPositionUseCaseProtocol { bookPositionUseCase }
    var bookHighlight: BookHighlightUseCaseProtocol { bookHighlightUseCase }
    @MainActor var highlightStore: any DCHighlightStoreProtocol { _highlightStore }
}
