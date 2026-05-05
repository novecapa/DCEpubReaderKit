//
//  DCNotesViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 10/11/25.
//

import Foundation
import DCEpubCore

final class DCNotesViewBuilder {
    @MainActor
    func build(highlight: DCHighlight,
               highlightStore: (any DCHighlightStoreProtocol)?,
               userPreferences: DCUserPreferencesProtocol) -> DCNotesView {
        let viewModel = DCNotesViewModel(
            highlight: highlight,
            highlightStore: highlightStore,
            userPreferences: userPreferences
        )
        return DCNotesView(viewModel: viewModel)
    }
}

final class DCNotesViewBuilderMock {
    @MainActor
    func build() -> DCNotesView {
        let highlight = DCHighlight(
            uuid: "preview-uuid",
            bookId: "preview-book",
            chapterId: "chapter01.xhtml",
            spineIndex: 0,
            type: .note,
            text: "Selected text for preview",
            coords: ""
        )
        let viewModel = DCNotesViewModel(
            highlight: highlight,
            highlightStore: nil,
            userPreferences: DCUserPreferencesMock()
        )
        return DCNotesView(viewModel: viewModel)
    }
}
