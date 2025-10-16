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

    var body: some View {
        Group {
            if let chapterURL = book.chapterURL(forSpineIndex: spineIndex) {
                ChapterWebView(
                    chapterURL: chapterURL,
                    readAccessURL: book.opfDirectoryURL,
                    opensExternalLinks: true
                )
                .ignoresSafeArea(edges: .bottom)
            } else {
                Text("Unable to resolve chapter at spine index \(spineIndex).")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationTitle(title ?? "Chapter \(spineIndex + 1)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Minimal stub to preview layout without real file URLs.
    // Replace with a real `EpubBook` and index in app runtime.
    Text("ReaderChapterView preview placeholder")
}
