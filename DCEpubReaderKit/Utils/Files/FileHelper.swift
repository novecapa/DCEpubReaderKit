//
//  FileHelper.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

final class FileHelper {

    private enum Constants {
        static let bookFolder = "books"
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

    func clearTempSubfolder(named name: String) {
        guard !name.isEmpty else { return }
        let target = getTempFolder().appendingPathComponent(name, isDirectory: true)
        if getFileManager().fileExists(atPath: target.path) {
            try? getFileManager().removeItem(at: target)
        }
    }
}
