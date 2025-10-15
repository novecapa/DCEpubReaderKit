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
