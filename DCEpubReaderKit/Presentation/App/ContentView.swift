//
//  ContentView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import SwiftUI

struct ContentView: View {

    @State private var book: EpubBook?
    @State private var errorMsg: String?
    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            List {
                if let book {
                    Section("Metadata") {
                        if let coverPath = book.metadata.coverHint {
                            CoverImageView(imagePath: coverPath)
                        }
                        KeyValueRow(key: "Title", value: book.metadata.title ?? "—")
                        KeyValueRow(key: "Author", value: book.metadata.creators.first ?? "—")
                        KeyValueRow(key: "Language", value: book.metadata.language ?? "—")
                        KeyValueRow(key: "Version", value: book.metadata.version ?? "—")
                        KeyValueRow(key: "OPF", value: book.packagePath)
                    }

                    Section("Spine (\(book.spine.count))") {
                        ForEach(Array(book.spine.enumerated()), id: \.offset) { index, spine in
                            NavigationLink {
                                ReaderChapterView(
                                    book: book,
                                    spineIndex: index,
                                    title: book.metadata.title ?? "Chapter"
                                )
                            } label: {
                                Text("• \(spine.idref) \(spine.linear ? "" : "(non-linear)")")
                                    .font(.body.monospaced())
                                    .accessibilityLabel("\(spine.idref) \(spine.linear ? "" : "non linear")")
                            }
                        }
                    }

                    Section("Table of Contents (\(book.toc.count))") {
                        TocList(nodes: book.toc, depth: 0)
                    }

                    Section("Resources (manifest)") {
                        ForEach(Array(book.manifest.enumerated()), id: \.offset) { _, item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(item.id) — \(item.mediaType)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if item.mediaType.contains("image") {
                                    ManifestImageRow(book: book, item: item)
                                }
                            }
                        }
                    }
                }

                if let errorMsg {
                    Section("Error") {
                        Text(errorMsg)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Error: \(errorMsg)")
                    }
                }
            }
            .navigationTitle("EPUB Inspector")
            .toolbar {
                Button("Open EPUB") { isPickerPresented = true }
            }
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.epub],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    do {
                        let folder = try EpubFileManager.shared.prepareBookFiles(epubFile: url)
                        self.book = try EpubParser.parse(from: folder)
                        self.errorMsg = nil
                    } catch {
                        self.errorMsg = "\(error)"
                        self.book = nil
                    }
                case .failure(let error):
                    self.errorMsg = "\(error)"
                }
            }
        }
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
        if let url = URL(string: imagePath),
           let uiImage = UIImage(contentsOfFile: url.path) {
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
    let nodes: [TocNode]
    let depth: Int

    var body: some View {
        ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(repeating: "  ", count: depth))• \(node.label) \(node.href ?? "")")
                    .font(.body.monospaced())
                    .accessibilityLabel("\(node.label) \(node.href ?? "")")
                if !node.children.isEmpty {
                    TocList(nodes: node.children, depth: depth + 1)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
