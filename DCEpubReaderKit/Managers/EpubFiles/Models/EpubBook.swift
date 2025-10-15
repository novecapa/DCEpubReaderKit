//
//  EpubBook.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

public struct EpubBook {
    public let version: String
    public let packagePath: String
    public let metadata: EpubMetadata
    public let manifest: [ManifestItem]
    public let spine: [SpineItemRef]
    public let toc: [TocNode]
    public let resourcesRoot: URL
}
