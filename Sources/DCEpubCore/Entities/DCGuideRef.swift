//
//  DCGuideRef.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct DCGuideRef {
    public let type: String?
    public let title: String?
    public let href: String

    public init(type: String?, title: String?, href: String) {
        self.type = type
        self.title = title
        self.href = href
    }
}
