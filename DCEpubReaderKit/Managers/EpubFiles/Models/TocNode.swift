//
//  TocNode.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct TocNode {
    public let label: String
    public let href: String?
    public var children: [TocNode]
}
