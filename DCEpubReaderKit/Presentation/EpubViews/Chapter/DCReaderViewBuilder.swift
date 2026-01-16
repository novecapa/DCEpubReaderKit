//
//  DCReaderViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import Foundation

final class DCReaderViewBuilder {
    func build(_ book: EpubBook,
               spineIndex: Int) -> DCReaderView {
        let userPreferences: DCUserPreferencesProtocol = DCUserPreferences(userPreferences: UserDefaults.standard)
        let database = BookPositionDatabase()
        let repository = BookPositionRepository(database: database)
        let useCase = BookPositionUseCase(repository: repository)
        let viewModel = DCReaderViewModel(
            book: book,
            spineIndex: spineIndex,
            userPreferencesProtocol: userPreferences,
            useCase: useCase
        )
        let view = DCReaderView(viewModel: viewModel)
        return view
    }
}

final class DCReaderViewBuilderMock {
    func build(_ book: EpubBook,
               spineIndex: Int) -> DCReaderView {
        let userPreferences: DCUserPreferencesProtocol = DCUserPreferencesMock()
        let database = BookPositionDatabaseMock()
        let repository = BookPositionRepository(database: database)
        let useCase = BookPositionUseCase(repository: repository)
        let viewModel = DCReaderViewModel(
            book: book,
            spineIndex: spineIndex,
            userPreferencesProtocol: userPreferences,
            useCase: useCase
        )
        let view = DCReaderView(viewModel: viewModel)
        return view
    }
}
