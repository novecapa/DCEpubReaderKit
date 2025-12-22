//
//  EpubMetadata.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct OPFMetadata {
    public var version: String?
    public var title: String?
    public var creators: [String] = []
    public var language: String?
    public var identifiers: [String] = []
    public var date: String?
    public var publisher: String?
    public var descriptionHTML: String?
    public var coverHint: String?

    static let mock: OPFMetadata = OPFMetadata(
        version: "2",
        title: "Book title",
        creators: ["DC Creator"],
        language: "es",
        identifiers: [""],
        date: "222",
        publisher: "publisher",
        descriptionHTML: "",
        coverHint: ""
    )
}
