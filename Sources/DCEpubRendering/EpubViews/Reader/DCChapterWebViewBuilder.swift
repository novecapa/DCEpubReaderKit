//
//  DCChapterWebViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 2/11/25.
//

import Foundation
import DCEpubCore

final class DCChapterWebViewBuilder {
    @MainActor
    func build(chapterURL: URL,
               readAccessURL: URL,
               spineIndex: Int,
               initialCoords: String?,
               userPreferences: DCUserPreferencesProtocol,
               bookId: String,
               highlightStore: (any DCHighlightStoreProtocol)?,
               onAction: @escaping (DCChapterViewAction) -> Void) -> DCChapterWebView {
        let viewModel = DCChapterWebViewModel(
            chapterURL: chapterURL,
            readAccessURL: readAccessURL,
            spineIndex: spineIndex,
            initialCoords: initialCoords,
            userPreferences: userPreferences,
            bookId: bookId,
            highlightStore: highlightStore,
            onAction: onAction
        )
        let view = DCChapterWebView(viewModel: viewModel)
        return view
    }
}
