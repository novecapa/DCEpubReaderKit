//
//  FileHelper.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

final class FileHelper {

    private enum Constants {
        static let bundleId = "DCEpubReaderKit"
        static let bookFolder = "books"
    }

    enum FolderType {
        case temporary
        case documents
    }

    enum FileType: String {
        case epub
    }

    static let shared = FileHelper()

    private init() {}

    private func getFileManager() -> FileManager {
        FileManager.default
    }

    func getDocumentsDirectory() -> URL {
        getFileManager().urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func getTempFolder() -> URL {
        getFileManager().temporaryDirectory
    }

    func getBooksDirectory() -> URL {
        let booksDirectory = getDocumentsDirectory().appendingPathComponent(Constants.bookFolder, isDirectory: true)
        if !getFileManager().fileExists(atPath: booksDirectory.path) {
            try? getFileManager().createDirectory(at: booksDirectory, withIntermediateDirectories: true)
        }
        return booksDirectory
    }

    func sanitizeFolderName(_ name: String) -> String {
        guard !name.isEmpty else { return UUID().uuidString }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitized = String(name.unicodeScalars.map { scalar -> Character in
            if allowed.contains(scalar) {
                return Character(scalar)
            }
            return "_"
        })
        return sanitized.isEmpty ? UUID().uuidString : sanitized
    }

    func saveUnzippedBook(from tempFolder: URL, bookId: String) throws -> URL {
        let safeId = sanitizeFolderName(bookId)
        let destination = getBooksDirectory().appendingPathComponent(safeId, isDirectory: true)
        if getFileManager().fileExists(atPath: destination.path) {
            try getFileManager().removeItem(at: destination)
        }
        try getFileManager().copyItem(at: tempFolder, to: destination)
        return destination
    }

    func createDirectory(at folderType: FolderType, directoryName: String) throws {
       guard !directoryName.isEmpty else { return }

        let fileManager = getFileManager()
        let documentsDirectory = folderType == .documents ? getDocumentsDirectory() : getTempFolder()

        guard !fileManager.fileExists(atPath: documentsDirectory.appendingPathComponent(directoryName).path) else {
            return
        }

        do {
            try fileManager.createDirectory(atPath: documentsDirectory
                .appendingPathComponent(directoryName)
                .relativePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw error
        }
    }

    func clearTempFolder() throws {
        do {
            let tmpDirURL = getFileManager().temporaryDirectory
            let tmpDirectory = try getFileManager().contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try getFileManager().removeItem(atPath: fileUrl.path)
            }
        } catch {
            throw error
        }
    }
}
