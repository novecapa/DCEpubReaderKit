//
//  MainViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import SwiftUI

final class MainViewModel: ObservableObject {

    @Published var books: [EBookEntity] = []
    @Published var errorMsg: String?
    @Published var isPickerPresented = false

    private let useCase: BookFileUseCaseProtocol

    init(useCase: BookFileUseCaseProtocol) {
        self.useCase = useCase
    }
}

// MARK: - Methods

extension MainViewModel {
    func loadBooks() {
        do {
            self.books = try useCase.getBookList()
        } catch {
            errorMsg = error.localizedDescription
        }
    }

    func fileImporterResult(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importBook(from: url)
            errorMsg = nil
        case .failure(let error):
            errorMsg = "\(error)"
        }
    }
}

// MARK: - Private

private extension MainViewModel {
    func importBook(from url: URL) {
        do {
            let booksRoot = FileHelper.shared.getBooksDirectory()
            let stagingBase = FileHelper.shared.getTempFolder()
                .appendingPathComponent(FileHelper.Constants.tempFolder, isDirectory: true)
            let stagingRoot = stagingBase
                .appendingPathComponent(UUID().uuidString, isDirectory: true)

            defer {
                try? FileManager.default.removeItem(at: stagingRoot)
                FileHelper.shared.clearTempSubfolder()
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
            try useCase.saveBook(book: persistedBook)
            loadBooks()
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}
