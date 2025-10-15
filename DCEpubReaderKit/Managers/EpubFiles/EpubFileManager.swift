//
//  EpubFileManager.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation
import ZIPFoundation

/// Represents errors that can occur while handling EPUB files.

enum EpubError: Error {
    case invalidEPUB
    case missingContainer
    case missingOPF
    case parseError(String)
    case unzipError(String)
}

/// Handles unzipping and preparing EPUB files for parsing.

final class EpubFileManager {

    static let shared = EpubFileManager()
    private init() {}

    /// Creates a unique temporary folder for unpacking an EPUB.
    private func prepareUniqueTempFolder() -> URL {
        let tempFolderId = UUID().uuidString
        let unzipRoot = FileHelper.shared.getTempFolder()
            .appendingPathComponent(tempFolderId, isDirectory: true)
        return unzipRoot
    }

    /// Extracts the contents of a given `.epub` file into a temporary directory.
    /// - Parameter epubFile: The EPUB file URL.
    /// - Returns: The URL of the unzipped root directory.
    /// - Throws: `EpubError.unzipError` if extraction fails.
    func prepareBookFiles(epubFile: URL) throws -> URL {
        let unzipRoot = prepareUniqueTempFolder()

        do {
            // Ensure destination directory exists
            try FileManager.default.createDirectory(at: unzipRoot, withIntermediateDirectories: true)

            // Begin security access if needed (for files chosen via FileImporter)
            let needsSecurityAccess = epubFile.startAccessingSecurityScopedResource()
            defer {
                if needsSecurityAccess { epubFile.stopAccessingSecurityScopedResource() }
            }

            // Copy the original EPUB file into the temp folder before extracting
            let copiedFileURL = unzipRoot.appendingPathComponent(epubFile.lastPathComponent)
            try FileManager.default.copyItem(at: epubFile, to: copiedFileURL)

            // Open the copied EPUB archive in read-only mode
            let archive = try Archive(url: copiedFileURL, accessMode: .read)

            // Extract all entries to the destination
            for entry in archive {
                let destinationURL = unzipRoot.appendingPathComponent(entry.path)

                // Ensure the subdirectory exists
                try FileManager.default.createDirectory(
                    at: destinationURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                // Extract file entry to destination
                _ = try archive.extract(entry, to: destinationURL)
            }

            return unzipRoot

        } catch {
            // Clean up if extraction fails
            try? FileManager.default.removeItem(at: unzipRoot)
            throw EpubError.unzipError("Failed to unzip EPUB: \(error.localizedDescription)")
        }
    }
}
