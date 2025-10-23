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

struct ReaderChapterView: View {

    let book: EpubBook
    /// Which spine item to load initially.
    let spineIndex: Int

    /// Optional heading/title to show in nav bar.
    var title: String?

    /// Current selected spine for the pager.
    @State private var currentSelection: Int
    @State private var previousSelection: Int

    @State var totalPages: Int = 1
    @State var currentPage: Int = 1
    @State private var canTouch: Bool = true

    init(book: EpubBook,
         spineIndex: Int,
         title: String?) {
        self.book = book
        self.spineIndex = spineIndex
        self.title = title
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
                                if let title = book.metadata.title {
                                    Text(title)
                                }
                                ChapterWebView(
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
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                Text("página \(currentPage) de \(totalPages)")
                            }
                            .opacity(canTouch ? 1 : 0)
                            .animation(.easeInOut(duration: 0.75), value: canTouch)

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
            .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    ReaderChapterView(book: .mock,
                      spineIndex: 0,
                      title: "Title")
}
