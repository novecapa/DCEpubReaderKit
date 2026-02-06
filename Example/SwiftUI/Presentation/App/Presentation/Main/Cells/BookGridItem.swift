//
//  BookGridItem.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import SwiftUI

struct BookGridItem: View {

    let book: EBookEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BookCoverView(coverPath: book.coverPath, basePath: book.basePath)
            Text(book.title.isEmpty ? "Untitled".localized() : book.title)
                .font(.headline)
                .lineLimit(2)
            Text(book.author.isEmpty ? "—" : book.author)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).strokeBorder(.quaternary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(book.title), \(book.author)")
    }
}

struct BookCoverView: View {

    private let coverPath: String
    private let basePath: URL?

    init(coverPath: String, basePath: URL?) {
        self.coverPath = coverPath
        self.basePath = basePath
    }

    var body: some View {
        let resolvedPath = resolveCoverPath()
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.12))
            if let resolvedPath,
               let uiImage = UIImage(contentsOfFile: resolvedPath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Text("No cover".localized())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(5.0 / 7.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityLabel("Cover".localized())
    }

    private func resolveCoverPath() -> String? {
        guard !coverPath.isEmpty else { return nil }

        if FileManager.default.fileExists(atPath: coverPath) {
            return coverPath
        }

        let candidate = basePath?.appendingPathComponent(coverPath).path
        return candidate
    }
}
