//
//  DCChapterWebViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 2/11/25.
//

import SwiftUI

final class DCChapterWebViewModel: ObservableObject {

    var showNotes: Bool = false
    weak var coordinator: DCChapterWebView.Coordinator?

    /// Absolute file URL of the HTML/XHTML chapter.
    let chapterURL: URL
    /// Directory granting read access to all relative resources (usually `opfDirectoryURL`).
    let readAccessURL: URL
    /// Index of the spine that this view represents (used for disambiguating async callbacks).
    let spineIndex: Int
    let userPreferences: DCUserPreferencesProtocol
    let onAction: (DCChapterViewAction) -> Void

    init(chapterURL: URL,
         readAccessURL: URL,
         spineIndex: Int,
         userPreferences: DCUserPreferencesProtocol,
         onAction: @escaping (DCChapterViewAction) -> Void) {
        self.chapterURL = chapterURL
        self.readAccessURL = readAccessURL
        self.spineIndex = spineIndex
        self.userPreferences = userPreferences
        self.onAction = onAction
    }
}

extension DCChapterWebViewModel: DCWebViewRouterProtocol {
    func showNoote() {
        onAction(.showNote)
    }

    @MainActor
    func updateCurrentPage(target: Int?) {
        coordinator?.updateCurrentPageInternal(target: target)
    }

    @MainActor
    func saveBookmark() {
        coordinator?.saveBookMark()
    }
}
