//
//  DCHighlightStoreProtocol.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 04/05/26.
//

import Foundation

@MainActor
public protocol DCHighlightStoreProtocol: AnyObject {
    func save(_ highlight: DCHighlight) async
    func highlights(bookId: String, chapterId: String) async -> [DCHighlight]
    func delete(uuid: String) async
}
