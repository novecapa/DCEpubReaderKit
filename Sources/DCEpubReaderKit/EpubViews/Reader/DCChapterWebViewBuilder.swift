//
//  DCChapterWebViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 2/11/25.
//

import Foundation

final class DCChapterWebViewBuilder {
    func build(chapterURL: URL,
               readAccessURL: URL,
               spineIndex: Int,
               userPreferences: DCUserPreferencesProtocol,
               onAction: @escaping (DCChapterViewAction) -> Void) -> DCChapterWebView {
        let viewModel = DCChapterWebViewModel(
            chapterURL: chapterURL,
            readAccessURL: readAccessURL,
            spineIndex: spineIndex,
            userPreferences: userPreferences,
            onAction: onAction
        )
        let view = DCChapterWebView(viewModel: viewModel)
        return view
    }
}
