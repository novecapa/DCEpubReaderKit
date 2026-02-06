//
//  DCReaderViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import Foundation

public final class DCReaderViewBuilder {
    @MainActor
    public static func build(_ book: DCEpubBook,
                             spineIndex: Int,
                             delegate: DCReaderCoordsProtocol?) -> DCReaderView {
        let userPreferences: DCUserPreferencesProtocol = DCUserPreferences(userPreferences: UserDefaults.standard)
        let viewModel = DCReaderViewModel(
            book: book,
            spineIndex: spineIndex,
            userPreferencesProtocol: userPreferences,
            delegate: delegate
        )
        DCFonts.registerAllFontsIfNeeded()
        let view = DCReaderView(viewModel: viewModel)
        return view
    }
}

final class DCReaderViewBuilderMock {
    @MainActor
    static func build(_ book: DCEpubBook,
                      spineIndex: Int) -> DCReaderView {
        let userPreferences: DCUserPreferencesProtocol = DCUserPreferencesMock()
        let viewModel = DCReaderViewModel(
            book: book,
            spineIndex: spineIndex,
            userPreferencesProtocol: userPreferences,
            delegate: nil
        )
        let view = DCReaderView(viewModel: viewModel)
        return view
    }
}
