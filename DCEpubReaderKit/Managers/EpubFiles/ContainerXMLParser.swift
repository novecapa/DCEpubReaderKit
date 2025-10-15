//
//  ContainerXMLParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

final class ContainerXMLParser: NSObject, XMLParserDelegate {

    private(set) var rootfilePath: String?
    private var currentElement: String = ""
    private var attributes: [String: String] = [:]

    func parse(url: URL) throws -> String {
        let containerURL = url.appendingPathComponent("META-INF/container.xml")
        guard FileManager.default.fileExists(atPath: containerURL.path) else {
            throw EpubError.missingContainer
        }
        let parser = XMLParser(contentsOf: containerURL)!
        parser.delegate = self
        guard parser.parse() else {
            throw EpubError.parseError("container.xml inválido")
        }
        guard let root = rootfilePath else {
            throw EpubError.missingOPF
        }
        return root
    }
    
    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = name
        attributes = attributeDict
        if name == "rootfile" {
            // 'full-path' -> .opf
            if let path = attributeDict["full-path"] {
                rootfilePath = path
            }
        }
    }
}
