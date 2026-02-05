//
//  ContentView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import SwiftUI

struct ContentView: View {

    @State private var errorMsg: String?
    @State private var isPickerPresented = false
    @State private var books: [RBook] = []

    private let bookDatabase = BookFileDatabase()
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if books.isEmpty {
                    EmptyLibraryView()
                        .padding(.top, 40)
                }

                if let errorMsg {
                    Text(errorMsg)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .accessibilityLabel("Error: \(errorMsg)")
                }

                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(books, id: \.uuid) { book in
                        BookGridItem(book: book)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Mi Biblioteca")
            .toolbar {
                Button("Open EPUB") { isPickerPresented = true }
            }
            .onAppear { loadBooks() }
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.epub],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    do {
                        try importBook(from: url)
                        self.errorMsg = nil
                    } catch {
                        self.errorMsg = "\(error)"
                    }
                case .failure(let error):
                    self.errorMsg = "\(error)"
                }
            }
        }
    }

    private func loadBooks() {
        do {
            self.books = try bookDatabase.getBookList()
        } catch {
            self.errorMsg = "\(error)"
        }
    }

    private func importBook(from url: URL) throws {
        let tempFolder = try EpubFileManager.shared.prepareBookFiles(epubFile: url)
        defer {
            try? FileManager.default.removeItem(at: tempFolder)
        }

        let tempBook = try EpubParser.parse(from: tempFolder)
        let persistedRoot = try FileHelper.shared.saveUnzippedBook(
            from: tempFolder,
            bookId: tempBook.uniqueIdentifier
        )

        let persistedBook = try EpubParser.parse(from: persistedRoot)
        try bookDatabase.saveBook(book: persistedBook)
        self.books = try bookDatabase.getBookList()
    }
}

// MARK: - Components

/// Simple “key: value” row with consistent styling.
private struct KeyValueRow: View {
    let key: String
    let value: String
    var body: some View {
        HStack {
            Text("\(key):")
                .fontWeight(.semibold)
            Text(value)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(key) \(value)")
    }
}

/// Displays the cover image from a file path (string).
private struct CoverImageView: View {
    let imagePath: String

    var body: some View {
        if !imagePath.isEmpty,
           let uiImage = UIImage(contentsOfFile: imagePath) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary)
                }
                .accessibilityLabel("Cover image")
        }
    }
}

private struct BookGridItem: View {
    let book: RBook

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BookCoverView(coverPath: book.coverPath, basePath: book.path)
            Text(book.title.isEmpty ? "Sin título" : book.title)
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

private struct BookCoverView: View {
    let coverPath: String
    let basePath: String

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
                Text("Sin portada")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(5.0 / 7.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityLabel("Portada")
    }

    private func resolveCoverPath() -> String? {
        guard !coverPath.isEmpty else { return nil }

        if coverPath.hasPrefix("file://"), let url = URL(string: coverPath) {
            let path = url.path
            if FileManager.default.fileExists(atPath: path) { return path }
        }

        if FileManager.default.fileExists(atPath: coverPath) {
            return coverPath
        }

        let candidate = URL(fileURLWithPath: basePath).appendingPathComponent(coverPath).path
        if FileManager.default.fileExists(atPath: candidate) {
            return candidate
        }

        let components = URL(fileURLWithPath: coverPath).pathComponents
        let knownRoots = ["oebps", "ops", "epub"]
        if let idx = components.lastIndex(where: { knownRoots.contains($0.lowercased()) }) {
            let rel = components[idx...].joined(separator: "/")
            let guessed = URL(fileURLWithPath: basePath).appendingPathComponent(rel).path
            if FileManager.default.fileExists(atPath: guessed) {
                return guessed
            }
        }

        for suffixCount in [3, 2] {
            if components.count >= suffixCount {
                let rel = components.suffix(suffixCount).joined(separator: "/")
                let guessed = URL(fileURLWithPath: basePath).appendingPathComponent(rel).path
                if FileManager.default.fileExists(atPath: guessed) {
                    return guessed
                }
            }
        }

        return nil
    }
}

private struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Tu biblioteca está vacía")
                .font(.headline)
            Text("Importa un .epub para empezar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
    }
}

/// Shows a manifest item if it’s an image, resolving its absolute file URL.
private struct ManifestImageRow: View {
    let book: EpubBook
    let item: ManifestItem

    var body: some View {
        let imageURL = book.resourcesRoot
            .appendingPathComponent(book.packagePath)
            .deletingLastPathComponent()
            .appendingPathComponent(item.href)
            .standardizedFileURL

        if let uiImage = UIImage(contentsOfFile: imageURL.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary)
                }
                .accessibilityLabel("Manifest image \(item.id)")
        } else {
            Text("⚠️ Could not load image at \(item.href)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Could not load image at \(item.href)")
        }
    }
}

// MARK: - TOC

struct TocList: View {
    let book: EpubBook
    let nodes: [TocNode]
    let depth: Int

    var body: some View {
        ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
            Group {
                if let idx = book.spineIndex(forTOCHref: node.href ?? "") {
                    NavigationLink {
                        DCReaderViewBuilder().build(book, spineIndex: idx)
                    } label: {
                        TocRow(book: book, node: node, depth: depth)
                    }
                }
                if !node.children.isEmpty {
                    TocList(book: book, nodes: node.children, depth: depth + 1)
                }
            }
        }
    }
}

private struct TocRow: View {
    let book: EpubBook
    let node: TocNode
    let depth: Int

    var body: some View {
        let hasHref = (book.spineIndex(forTOCHref: node.href ?? "") != nil)
        let text = Text("• \(node.label)")

        if hasHref {
            text
                .font(.body)
                .padding(.leading, CGFloat(depth) * 12)
                .accessibilityLabel("\(node.label)")
        } else {
            // Non-addressable TOC node (e.g., section header without href)
            text
                .font(.body.weight(.semibold))
                .padding(.leading, CGFloat(depth) * 12)
                .accessibilityLabel("\(node.label)")
        }
    }
}

#Preview {
    ContentView()
}
