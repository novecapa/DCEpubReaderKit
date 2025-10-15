//
//  EpubBook.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

public struct EpubBook {
    public let packagePath: String
    public let metadata: OPFMetadata
    public let manifest: [ManifestItem]
    public let spine: [SpineItem]
    public let toc: [TocNode]
    public let resourcesRoot: URL
}
