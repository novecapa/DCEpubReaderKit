//
//  EpubFileManager.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation
import ZIPFoundation

enum EpubError: Error {
    case invalidEPUB
    case missingContainer
    case missingOPF
    case parseError(String)
    case unzipError(String)
}

final class EpubFileManager {

    static let shared = EpubFileManager()

    private init() {}

    private func createUniqueTempFolder() -> URL {
        let tempFolderId = UUID().uuidString
        let unzipRoot = FileHelper.shared.getTempFolder()
            .appendingPathComponent(tempFolderId)
        return unzipRoot
    }

    func prepareBookFiles(epubFile: URL) throws -> URL {
        let unzipRoot = createUniqueTempFolder()
        do {
            let archive = try Archive(url: epubFile, accessMode: .read)
            for entry in archive {
                let outURL = unzipRoot.appendingPathComponent(entry.path)
                try FileManager.default.createDirectory(at: outURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true)
                _ = try archive.extract(entry, to: outURL)
            }
            return unzipRoot
        } catch {
            throw EpubError.unzipError("No se pudo abrir el zip: \(error.localizedDescription)")
        }
    }
}
