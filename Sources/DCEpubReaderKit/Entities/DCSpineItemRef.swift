//
//  DCSpineItemRef.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct DCSpineItem: Sendable {
    public let idref: String
    public let linear: Bool

    static let mock: DCSpineItem = DCSpineItem(idref: "", linear: false)
}
