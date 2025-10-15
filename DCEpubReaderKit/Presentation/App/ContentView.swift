//
//  ContentView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @State private var book: EpubBook?
    @State private var errorMsg: String?
    @State private var isPickerPresented = false
    
    var body: some View {
        NavigationView {
            List {
                if let book {
                    Section("Metadata") {
                        Text("Title: \(book.metadata.title ?? "—")")
                        Text("Author: \(book.metadata.creator ?? "—")")
                        Text("Language: \(book.metadata.language ?? "—")")
                        Text("Version: \(book.version)")
                        Text("OPF: \(book.packagePath)")
                    }
                    Section("Spine (\(book.spine.count))") {
                        ForEach(Array(book.spine.enumerated()), id: \.offset) { _, s in
                            Text("• \(s.idref) \(s.linear ? "" : "(non-linear)")")
                        }
                    }
                    Section("TOC (\(book.toc.count))") {
                        TocList(nodes: book.toc, depth: 0)
                    }
                    Section("Resources (manifest)") {
                        ForEach(Array(book.manifest.enumerated()), id: \.offset) { _, m in
                            Text("\(m.id) — \(m.mediaType)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if m.mediaType.contains("image") {
                                let imageURL = book.resourcesRoot
                                    .appendingPathComponent(book.packagePath).deletingLastPathComponent()
                                    .appendingPathComponent(m.href).standardizedFileURL
                                
                                if let uiImage = UIImage(contentsOfFile: imageURL.path) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary)
                                        }
                                } else {
                                    Text("⚠️ No se pudo cargar imagen en \(m.href)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                if let errorMsg {
                    Section("Error") { Text(errorMsg).foregroundStyle(.red) }
                }
            }
            .navigationTitle("EPUB Debug")
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

struct TocList: View {
    let nodes: [TocNode]
    let depth: Int
    
    var body: some View {
        ForEach(Array(nodes.enumerated()), id: \.offset) { _, n in
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(repeating: "  ", count: depth))• \(n.label) \(n.href ?? "")")
                    .font(.body.monospaced())
                if !n.children.isEmpty {
                    TocList(nodes: n.children, depth: depth + 1)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
