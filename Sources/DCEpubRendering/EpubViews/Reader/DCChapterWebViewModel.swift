//
//  DCChapterWebViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 2/11/25.
//

import SwiftUI
import DCEpubCore

@MainActor
final class DCChapterWebViewModel: ObservableObject {

    var showNotes: Bool = false
    weak var coordinator: DCChapterWebView.Coordinator?

    /// Absolute file URL of the HTML/XHTML chapter.
    let chapterURL: URL
    /// Directory granting read access to all relative resources (usually `opfDirectoryURL`).
    let readAccessURL: URL
    /// Index of the spine that this view represents (used for disambiguating async callbacks).
    let spineIndex: Int
    let initialCoords: String?
    let userPreferences: DCUserPreferencesProtocol
    let onAction: (DCChapterViewAction) -> Void
    let bookId: String
    let highlightStore: (any DCHighlightStoreProtocol)?

    init(chapterURL: URL,
         readAccessURL: URL,
         spineIndex: Int,
         initialCoords: String?,
         userPreferences: DCUserPreferencesProtocol,
         bookId: String,
         highlightStore: (any DCHighlightStoreProtocol)?,
         onAction: @escaping (DCChapterViewAction) -> Void) {
        self.chapterURL = chapterURL
        self.readAccessURL = readAccessURL
        self.spineIndex = spineIndex
        self.initialCoords = initialCoords
        self.userPreferences = userPreferences
        self.bookId = bookId
        self.highlightStore = highlightStore
        self.onAction = onAction
    }
}

extension DCChapterWebViewModel: DCWebViewRouterProtocol {

    func showNoote(highlight: DCHighlight) {
        onAction(.showNote(highlight: highlight))
    }

    func saveHighlight(_ highlight: DCHighlight) async {
        await highlightStore?.save(highlight)
    }

    func loadHighlights() async -> [DCHighlight] {
        await highlightStore?.highlights(bookId: bookId, chapterId: currentChapterId) ?? []
    }

    func deleteHighlight(uuid: String) async {
        await highlightStore?.delete(uuid: uuid)
    }

    var currentBookId: String { bookId }
    var currentChapterId: String { chapterURL.lastPathComponent }
    var currentSpineIndex: Int { spineIndex }

    func updateCurrentPage(target: Int?) {
        coordinator?.updateCurrentPageInternal(target: target)
    }

    func saveBookmark() {
        coordinator?.saveBookMark()
    }
}
