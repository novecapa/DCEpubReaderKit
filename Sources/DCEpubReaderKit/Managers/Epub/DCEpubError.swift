//
//  DCEpubError.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/2/26.
//

/// Represents errors that can occur while handling EPUB files.
enum DCEpubError: Error {
    case invalidEPUB
    case missingContainer
    case missingOPF
    case parseError(String)
    case unzipError(String)
}
