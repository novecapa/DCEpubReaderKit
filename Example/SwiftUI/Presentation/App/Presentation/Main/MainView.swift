//
//  MainView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import DCEpubReaderKit
import SwiftUI
internal import UniformTypeIdentifiers

struct MainView: View {

    @ObservedObject var viewModel: MainViewModel

    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.books.isEmpty {
                    emptyLibraryView
                        .padding(.top, 40)
                }
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(viewModel.books, id: \.uuid) { book in
                        NavigationLink {
                            if let ebook = viewModel.getEpubBook(book: book) {
                                DCReaderViewBuilder.build(ebook, spineIndex: 0, delegate: viewModel)
                            }
                        } label: {
                            BookGridItem(book: book)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .navigationTitle("My Library".localized())
            .toolbar {
                Button("Import EPUB".localized()) {
                    viewModel.isPickerPresented = true
                }
            }
            .onAppear {
                viewModel.loadBooks()
            }
            .fileImporter(
                isPresented: $viewModel.isPickerPresented,
                allowedContentTypes: [.epub],
                allowsMultipleSelection: false
            ) { result in
                viewModel.fileImporterResult(result)
            }
        }
    }

    private var emptyLibraryView: some View {
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

#Preview {
    MainViewBuilder().build()
}
