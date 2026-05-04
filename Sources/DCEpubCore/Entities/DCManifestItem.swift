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

    public init(id: String,
                href: String,
                mediaType: String,
                properties: String? = nil) {
        self.id = id
        self.href = href
        self.mediaType = mediaType
        self.properties = properties
    }

    static let mock: DCManifestItem = DCManifestItem(id: "", href: "", mediaType: "")
}
