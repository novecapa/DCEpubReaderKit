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
        let viewModel = DCReaderViewModel(
            book: book,
            spineIndex: spineIndex,
            userPreferencesProtocol: userPreferences
        )
        let view = DCReaderView(viewModel: viewModel)
        return view
    }
}

final class DCReaderViewBuilderMock {
    func build(_ book: EpubBook,
               spineIndex: Int) -> DCReaderView {
        let userPreferences: DCUserPreferencesProtocol = DCUserPreferencesMock()
        let viewModel = DCReaderViewModel(
            book: book,
            spineIndex: spineIndex,
            userPreferencesProtocol: userPreferences
        )
        let view = DCReaderView(viewModel: viewModel)
        return view
    }
}
