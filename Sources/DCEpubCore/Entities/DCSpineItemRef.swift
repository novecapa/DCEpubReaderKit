//
//  DCSpineItemRef.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct DCSpineItem: Sendable {
    public let idref: String
    public let linear: Bool

    public init(idref: String, linear: Bool) {
        self.idref = idref
        self.linear = linear
    }

    static let mock: DCSpineItem = DCSpineItem(idref: "", linear: false)
}
