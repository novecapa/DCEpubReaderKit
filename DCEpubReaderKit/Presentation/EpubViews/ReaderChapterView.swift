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

    init(book: EpubBook, spineIndex: Int, title: String?) {
        self.book = book
        self.spineIndex = spineIndex
        self.title = title
        _selection = State(initialValue: spineIndex)
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<book.spine.count, id: \.self) { idx in
                Group {
                    if let chapterURL = book.chapterURL(forSpineIndex: idx) {
                        ChapterWebView(
                            chapterURL: chapterURL,
                            readAccessURL: book.opfDirectoryURL,
                            opensExternalLinks: true
                        )
                        .padding(16)
                    } else {
                        Text("Unable to resolve chapter at spine index \(idx).")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .navigationTitle(title ?? "Chapter \(selection + 1)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Text("ReaderChapterView preview placeholder")
}
