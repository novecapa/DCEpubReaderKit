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
                        .accessibilityLabel("Error: \(errorMsg)".localized())
                }

                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(books, id: \.uuid) { book in
                        BookGridItem(book: book)
                    }
                }
                .padding(16)
            }
            .navigationTitle("My Library".localized())
            .toolbar {
                Button("Import EPUB".localized()) { isPickerPresented = true }
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
        let booksRoot = FileHelper.shared.getBooksDirectory()
        let stagingBaseName = "DCEpubReaderKit_import"
        let stagingBase = FileHelper.shared.getTempFolder()
            .appendingPathComponent(stagingBaseName, isDirectory: true)
        let stagingRoot = stagingBase
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        defer {
            try? FileManager.default.removeItem(at: stagingRoot)
            FileHelper.shared.clearTempSubfolder(named: stagingBaseName)
        }

        let unzipRoot = try EpubFileManager.shared.prepareBookFiles(
            epubFile: url,
            destinationRoot: stagingRoot
        )

        let parsedBook = try EpubParser.parse(from: unzipRoot)
        let finalId = FileHelper.shared.sanitizeFolderName(parsedBook.uniqueIdentifier)
        let finalRoot = booksRoot.appendingPathComponent(finalId, isDirectory: true)

        if FileManager.default.fileExists(atPath: finalRoot.path) {
            try FileManager.default.removeItem(at: finalRoot)
        }
        try FileManager.default.moveItem(at: unzipRoot, to: finalRoot)

        let persistedBook = try EpubParser.parse(from: finalRoot)
        try bookDatabase.saveBook(book: persistedBook)
        self.books = try bookDatabase.getBookList()
    }
}

// MARK: - Components

private struct BookGridItem: View {
    let book: RBook

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let booksRoot = FileHelper.shared.getBooksDirectory()
            BookCoverView(coverPath: book.coverPath, basePath: booksRoot.appending(path: book.uuid))
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

private struct BookCoverView: View {
    let coverPath: String
    let basePath: URL

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

        let candidate = basePath.appendingPathComponent(coverPath).path
        return candidate
    }
}

private struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Your library is empty".localized())
                .font(.headline)
            Text("Import an .epub to get started.".localized())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
    }
}

/// Shows a manifest item if it’s an image, resolving its absolute file URL.
#Preview {
    ContentView()
}
