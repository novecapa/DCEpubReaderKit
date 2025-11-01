//
//  DCReaderViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import SwiftUI

final class DCReaderViewModel: ObservableObject {

    // MARK: Config values
    @State var textSize: CGFloat
    @State var textFont: String
    @State var desktopMode: String

    // Current selected spine for the pager
    @State var currentSelection: Int
    @State var previousSelection: Int

    @State var totalPages: Int = 1
    @State var currentPage: Int = 1
    @State var canTouch: Bool = true

    @State var showSettings: Bool = false
    @State var settingsSheetHeight: CGFloat = 0

    private let book: EpubBook
    private let spineIndex: Int
    private let userPreferencesProtocol: DCUserPreferencesProtocol

    init(book: EpubBook,
         spineIndex: Int,
         userPreferencesProtocol: DCUserPreferencesProtocol) {
        self.book = book
        self.spineIndex = spineIndex
        self.userPreferencesProtocol = userPreferencesProtocol
        _currentSelection = State(initialValue: spineIndex)
        _previousSelection = State(initialValue: spineIndex)
        _textFont = State(initialValue: userPreferencesProtocol.getString(for: .fontFamily) ?? "original")
        _desktopMode = State(initialValue: userPreferencesProtocol.getString(for: .desktopMode) ?? "")
        _textSize = State(initialValue: userPreferencesProtocol.getCGFloat(for: .fontSize) ?? 4)
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
