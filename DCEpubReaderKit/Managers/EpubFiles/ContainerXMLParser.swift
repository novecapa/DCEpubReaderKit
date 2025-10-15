//
//  ContainerXMLParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

/// Parses `META-INF/container.xml` to locate the path of the OPF (rootfile).

final class ContainerXMLParser: NSObject, XMLParserDelegate {

    private(set) var rootfilePath: String?

    /// Parses the given unzipped EPUB folder URL and returns the OPF relative path
    /// declared in `META-INF/container.xml`.
    /// - Parameter url: The root folder of the unzipped EPUB.
    /// - Returns: The `full-path` to the OPF file (relative to `url`).
    /// - Throws: `EpubError.missingContainer`, `EpubError.parseError`, or `EpubError.missingOPF`.
    func parse(url: URL) throws -> String {
        let containerURL = url.appendingPathComponent("META-INF/container.xml")
        guard FileManager.default.fileExists(atPath: containerURL.path) else {
            throw EpubError.missingContainer
        }

        guard let parser = XMLParser(contentsOf: containerURL) else {
            throw EpubError.parseError("Unable to initialize XMLParser for container.xml")
        }

        // Reset state before parsing
        rootfilePath = nil

        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            throw EpubError.parseError("Invalid container.xml")
        }
        guard let root = rootfilePath, !root.isEmpty else {
            throw EpubError.missingOPF
        }
        return root
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser,
                didStartElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        // The OPF path is inside <rootfile full-path="..." />
        if name == "rootfile", rootfilePath == nil, let path = attributeDict["full-path"], !path.isEmpty {
            rootfilePath = path
        }
    }
}
