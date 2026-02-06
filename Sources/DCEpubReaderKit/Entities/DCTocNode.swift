//
//  DCTocNode.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct DCTocNode: Sendable {
    public let label: String
    public let href: String?
    public var children: [DCTocNode]

    static let mock: DCTocNode = DCTocNode(label: "DCTocNode", href: "", children: [.mock])
}
