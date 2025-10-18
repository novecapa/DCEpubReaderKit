//
//  ReaderChapterView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 16/10/25.
//

import SwiftUI

struct ReaderChapterView: View {

    let book: EpubBook
    /// Which spine item to load initially.
    let spineIndex: Int

    /// Optional heading/title to show in nav bar.
    var title: String?

    /// Current selected spine for the pager.
    @State private var selection: Int

    init(
        book: EpubBook,
        spineIndex: Int,
        title: String?
    ) {
        self.book = book
        self.spineIndex = spineIndex
        self.title = title
        _selection = State(initialValue: spineIndex)
    }

    var body: some View {
        ZStack {
            Color(.backgroundLight)
                .ignoresSafeArea(edges: .all)
            TabView(selection: $selection) {
                ForEach(0..<book.spine.count, id: \.self) { idx in
                    Group {
                        if let chapterURL = book.chapterURL(forSpineIndex: idx) {
                            VStack {
                                Text("titulo")
                                ChapterWebView(
                                    chapterURL: chapterURL,
                                    readAccessURL: book.opfDirectoryURL,
                                    opensExternalLinks: true
                                ) { action in
                                    print("action: \(action)")
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                Text("página")
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
            .navigationTitle(title ?? book.chapterTitle(forSpineIndex: selection) ?? "Chapter \(selection + 1)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ReaderChapterView(book: .mock,
                      spineIndex: 0,
                      title: "Title")
}
