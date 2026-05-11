//
//  DCReaderProtocols.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/2/26.
//

import Foundation
import DCEpubCore

@MainActor
public protocol DCReaderCoordsProtocol {
    func handleCoords(book: DCEpubBook,
                      spineIndex: Int,
                      coords: String,
                      chapterURL: URL?,
                      isBookMark: Bool)

    func save(highlight: DCHighlight) async
    func deleteHighlight(uuid: String, book: DCEpubBook) async
    func highlights(for book: DCEpubBook) async -> [DCHighlight]?
    func highlights(for book: DCEpubBook, chapterId: String) async -> [DCHighlight]?
}

public extension DCReaderCoordsProtocol {
    func save(highlight: DCHighlight) async {}

    func deleteHighlight(uuid: String, book: DCEpubBook) async {}

    func highlights(for book: DCEpubBook) async -> [DCHighlight]? {
        nil
    }

    func highlights(for book: DCEpubBook, chapterId: String) async -> [DCHighlight]? {
        nil
    }
}

@MainActor
protocol DCChapterReaderContextProtocol: AnyObject {
    var currentBook: DCEpubBook { get }
    var bookId: String { get }
    func consumeInitialCoords(for spineIndex: Int, chapterURL: URL) -> String?
    func showNote(highlight: DCHighlight)
    func save(highlight: DCHighlight) async
    func deleteHighlight(uuid: String) async
    func highlights(for chapterId: String) async -> [DCHighlight]
}
