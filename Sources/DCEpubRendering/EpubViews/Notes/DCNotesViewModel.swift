//
//  DCNotesViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 10/11/25.
//

import SwiftUI
import DCEpubCore

@MainActor
final class DCNotesViewModel: ObservableObject {

    @Published var note: String

    private var highlight: DCHighlight
    private let highlightStore: (any DCHighlightStoreProtocol)?
    private let userPreferences: DCUserPreferencesProtocol
    private var saveTask: Task<Void, Never>?

    init(highlight: DCHighlight,
         highlightStore: (any DCHighlightStoreProtocol)?,
         userPreferences: DCUserPreferencesProtocol) {
        self.highlight = highlight
        self.highlightStore = highlightStore
        self.userPreferences = userPreferences
        self.note = highlight.note
    }

    var backgroundColor: Color {
        userPreferences.getDesktopMode().backgroundColor
    }

    var textColor: Color {
        userPreferences.getDesktopMode().textColor
    }

    func noteDidChange(_ text: String) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            var updated = highlight
            updated.note = text
            updated.dateUpdated = Date().timeIntervalSince1970
            highlight = updated
            await highlightStore?.save(updated)
        }
    }
}
