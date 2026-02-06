//
//  DCEpubMetadata.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

public struct DCOPFMetadata: Sendable {
    public var version: String?
    public var title: String?
    public var creators: [String] = []
    public var language: String?
    /// Stores raw OPF `dc:identifier` values as strings.
    public var identifiers: [String] = []
    public var date: String?
    public var publisher: String?
    public var descriptionHTML: String?
    public var coverHint: String?

    static let mock: DCOPFMetadata = DCOPFMetadata(
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
