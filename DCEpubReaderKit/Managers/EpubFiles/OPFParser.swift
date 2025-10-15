//
//  OPFParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

final class OPFParser: NSObject, XMLParserDelegate {

    private(set) var version: String = "2.0"
    private(set) var metadata = EpubMetadata()
    private(set) var manifest: [ManifestItem] = []
    private(set) var spine: [SpineItemRef] = []
    
    private var currentElement = ""
    private var currentText = ""
    private var inMetadata = false
    private var inManifest = false
    private var inSpine = false
    
    func parse(opfURL: URL) throws {
        let parser = XMLParser(contentsOf: opfURL)!
        parser.delegate = self
        guard parser.parse() else {
            throw EpubError.parseError("Can not parser the OPF")
        }
    }
    
    // MARK: XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName qName: String?, attributes a: [String : String] = [:]) {
        currentElement = name
        currentText = ""
        if name.lowercased() == "package" {
            if let v = a["version"] { version = v }
        } else if name.lowercased() == "metadata" {
            inMetadata = true
        } else if name.lowercased() == "manifest" {
            inManifest = true
        } else if name.lowercased() == "spine" {
            inSpine = true
        } else if inManifest && name.lowercased() == "item" {
            manifest.append(ManifestItem(
                id: a["id"] ?? UUID().uuidString,
                href: a["href"] ?? "",
                mediaType: a["media-type"] ?? "",
                properties: a["properties"]
            ))
        } else if inSpine && name.lowercased() == "itemref" {
            spine.append(SpineItemRef(
                idref: a["idref"] ?? "",
                linear: (a["linear"] ?? "yes").lowercased() != "no"
            ))
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName qName: String?) {
        if inMetadata {
            switch name.lowercased() {
            case "dc:title", "title":
                let metadataTitle = metadata.title ?? ""
                let newTitle = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                metadata.title = metadataTitle.isEmpty ? newTitle : metadataTitle
            case "dc:creator", "creator":
                let metadataCreator = metadata.creator ?? ""
                let newCreator = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                metadata.creator = metadataCreator.isEmpty ? newCreator : metadataCreator
            case "dc:language", "language":
                let metadataLanguage = metadata.language ?? ""
                let newLanguage = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                metadata.language = metadataLanguage.isEmpty ? newLanguage : metadataLanguage
            case "dc:identifier", "identifier":
                let metadataIdentifier = metadata.identifier ?? ""
                let newIdentifier = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                metadata.identifier = metadataIdentifier.isEmpty ? newIdentifier : metadataIdentifier
            case "metadata":
                inMetadata = false
            default: break
            }
        } else if name.lowercased() == "manifest" {
            inManifest = false
        } else if name.lowercased() == "spine" {
            inSpine = false
        }
    }
}
