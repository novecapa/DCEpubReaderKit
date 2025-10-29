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

struct DCReaderChapterView: View {

    private enum Constants {
        static let frameSize: CGFloat = 32
    }

    @Environment(\.dismiss) var dismiss

    /// Current selected spine for the pager.
    @State private var currentSelection: Int
    @State private var previousSelection: Int

    @State var totalPages: Int = 1
    @State var currentPage: Int = 1
    @State private var canTouch: Bool = true

    @State private var showSettings: Bool = false

    private let book: EpubBook
    private let spineIndex: Int
    private let userPreferences: DCUserPreferencesProtocol

    init(book: EpubBook,
         spineIndex: Int,
         userPreferences: DCUserPreferencesProtocol) {
        self.book = book
        self.spineIndex = spineIndex
        self.userPreferences = userPreferences
        _currentSelection = State(initialValue: spineIndex)
        _previousSelection = State(initialValue: spineIndex)
    }

    var body: some View {
        ZStack {
            Color(.backgroundLight)
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
                                    case .coordsFirstNodeOfPage(orientation: let orientation,
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
                                if totalPages > 1 {
                                    Text("página \(currentPage) de \(totalPages)")
                                        .opacity(canTouch ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.25), value: canTouch)
                                }
                            }

                        } else {
                            Text("Unable to resolve chapter at spine index \(idx).")
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle(book.metadata.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbarRole(.editor)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .tint(.gray)
                            .frame(width: Constants.frameSize,
                                   height: Constants.frameSize)
                            .padding(8)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .scaledToFit()
                            .tint(.gray)
                            .frame(width: Constants.frameSize,
                                   height: Constants.frameSize)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                // TODO: --
            } content: {
                DCReaderSettingsView()
                    .presentationDetents([.medium])
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
    DCReaderChapterView(book: .mock,
                        spineIndex: 0,
                        userPreferences: DCUserPreferencesMock())
}

#endif
