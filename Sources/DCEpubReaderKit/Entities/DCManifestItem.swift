//
//  DCManifestItem.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct DCManifestItem: Sendable {
    public let id: String
    public let href: String
    public let mediaType: String
    public var properties: String?

    static let mock: DCManifestItem = DCManifestItem(id: "", href: "", mediaType: "")
}
