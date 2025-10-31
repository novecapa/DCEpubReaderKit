//
//  ReaderChapterView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 16/10/25.
//

import SwiftUI

extension Notification.Name {
    static let chapterShouldScrollToLastPage = Notification.Name("chapterShouldScrollToLastPage")
}

struct DCReaderView: View {

    private enum Constants {
        static let frameSize: CGFloat = 32
    }

    @Environment(\.dismiss) var dismiss

    // MARK: Config values
    @State var textSize: CGFloat
    @State var textFont: String
    @State var desktopMode: String

    /// Current selected spine for the pager.
    @State private var currentSelection: Int
    @State private var previousSelection: Int

    @State var totalPages: Int = 1
    @State var currentPage: Int = 1
    @State private var canTouch: Bool = true

    @State var showSettings: Bool = false
    @State var settingsSheetHeight: CGFloat = 0

    private let book: EpubBook
    private let spineIndex: Int
    private let userPreferencesProtocol: DCUserPreferencesProtocol

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

    init(book: EpubBook,
         spineIndex: Int,
         userPreferencesProtocol: DCUserPreferencesProtocol = DCUserPreferences(userPreferences: UserDefaults.standard)) {
        self.book = book
        self.spineIndex = spineIndex
        self.userPreferencesProtocol = userPreferencesProtocol
        _currentSelection = State(initialValue: spineIndex)
        _previousSelection = State(initialValue: spineIndex)
        _textFont = State(initialValue: userPreferencesProtocol.getString(for: .fontFamily) ?? "original")
        _desktopMode = State(initialValue: userPreferencesProtocol.getString(for: .desktopMode) ?? "")
        _textSize = State(initialValue: userPreferencesProtocol.getCGFloat(for: .fontSize) ?? 4)
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea(edges: .all)
            TabView(selection: $currentSelection) {
                ForEach(0..<book.spine.count, id: \.self) { idx in
                    Group {
                        if let chapterURL = book.chapterURL(forSpineIndex: idx) {
                            VStack {
                                DCChapterWebView(
                                    chapterURL: chapterURL,
                                    readAccessURL: book.opfDirectoryURL,
                                    spineIndex: idx
                                ) { action in
                                    switch action {
                                    case .totalPageCount(let count, let spineIndex):
                                        if spineIndex == self.currentSelection {
                                            self.totalPages = count
                                            if self.currentPage > count {
                                                self.currentPage = count
                                            }
                                        }
                                    case .currentPage(index: let index,
                                                      totalPages: let totalPages,
                                                      spineIndex: let spineIndex):
                                        if spineIndex == self.currentSelection {
                                            self.totalPages = totalPages
                                            self.currentPage = index
                                        }
                                    case .canTouch(let enabled):
                                        self.canTouch = enabled
                                    case .coordsFirstNodeOfPage(orientation: _,
                                                                spineIndex: let spineIndex,
                                                                coords: let coords):
                                        if spineIndex == self.currentSelection {
                                            // TODO: - Save book position
                                            print("chapterFile: \(chapterURL.lastPathComponent) coords: \(coords)")
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .id("\(idx)-\(textFont)-\(desktopMode)-\(textSize)")
                                if totalPages > 1 {
                                    Text("página \(currentPage) de \(totalPages)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(textColor)
                                        .opacity(canTouch ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.25), value: canTouch)
                                }
                            }

                        } else {
                            Text("Unable to resolve chapter at spine index \(idx).")
                                .foregroundStyle(textColor)
                                .padding()
                        }
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                toolbarView
            }
            .sheet(isPresented: $showSettings) {
                sheetSettingsView
            }
        }
        .onChange(of: currentSelection) { _ in
            defer {
                previousSelection = currentSelection
            }
            NotificationCenter.default.post(
                name: .chapterShouldScrollToLastPage,
                object: nil,
                userInfo: currentSelection < previousSelection ? ["spineIndex": currentSelection] : nil
            )
        }
    }
}

#if DEBUG

#Preview {
    DCReaderView(book: .mock,
                 spineIndex: 0,
                 userPreferencesProtocol: DCUserPreferencesMock())
}

#endif
