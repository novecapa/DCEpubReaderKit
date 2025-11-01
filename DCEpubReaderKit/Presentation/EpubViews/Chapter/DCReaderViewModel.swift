//
//  DCReaderViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import SwiftUI

final class DCReaderViewModel: ObservableObject {

    // MARK: Config values
    @Published var textSize: CGFloat
    @Published var textFont: String
    @Published var desktopMode: String

    // Current selected spine for the pager
    @Published var currentSelection: Int
    @Published var previousSelection: Int

    @Published var totalPages: Int = 1
    @Published var currentPage: Int = 1
    @Published var canTouch: Bool = true

    @Published var showSettings: Bool = false
    @Published var settingsSheetHeight: CGFloat = 0

    private let book: EpubBook
    private let spineIndex: Int
    private let userPreferencesProtocol: DCUserPreferencesProtocol

    init(book: EpubBook,
         spineIndex: Int,
         userPreferencesProtocol: DCUserPreferencesProtocol) {
        self.book = book
        self.spineIndex = spineIndex
        self.userPreferencesProtocol = userPreferencesProtocol

        // Initial values
        self.currentSelection = spineIndex
        self.previousSelection = spineIndex
        self.textFont = userPreferencesProtocol.getString(for: .fontFamily) ?? "original"
        self.desktopMode = userPreferencesProtocol.getString(for: .desktopMode) ?? ""
        self.textSize = userPreferencesProtocol.getCGFloat(for: .fontSize) ?? 4

        // Defaults
        self.totalPages = 1
        self.currentPage = 1
        self.canTouch = true
        self.showSettings = false
        self.settingsSheetHeight = 0
    }

    var bookSpines: [SpineItem] {
        book.spine
    }

    func chapterURL(for idx: Int) -> URL? {
        book.chapterURL(forSpineIndex: idx)
    }

    var opfDirectoryURL: URL {
        book.opfDirectoryURL
    }

    func readerConfigId(for idx: Int) -> String {
        "\(idx)-\(textFont)-\(desktopMode)-\(textSize)"
    }

    var pageInfo: String {
        "página \(currentPage) de \(totalPages)"
    }

    var backgroundColor: Color {
        let desktopMode = userPreferences.getString(for: .desktopMode) ?? ""
        switch desktopMode {
        case "nightMode", "redMode":
            return Color(.backgroundNight)
        default:
            return Color(.backgroundLight)
        }
    }

    var textColor: Color {
        let desktopMode = userPreferences.getString(for: .desktopMode) ?? ""
        switch desktopMode {
        case "nightMode", "redMode":
            return Color(.backgroundLight)
        default:
            return Color(.backgroundNight)
        }
    }

    var bookTitle: String {
        book.metadata.title ?? ""
    }

    var userPreferences: DCUserPreferencesProtocol {
        userPreferencesProtocol
    }
}
