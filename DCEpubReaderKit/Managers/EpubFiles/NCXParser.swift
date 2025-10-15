//
//  NCXParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

final class NCXParser: NSObject, XMLParserDelegate {
    private var stack: [TocNode] = []
    private(set) var roots: [TocNode] = []
    private var currentText = ""
    private var currentHref: String?
    
    func parse(ncxURL: URL) throws -> [TocNode] {
        let parser = XMLParser(contentsOf: ncxURL)!
        parser.delegate = self
        guard parser.parse() else {
            throw EpubError.parseError("NCX not valid")
        }
        return roots
    }
    
    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName qName: String?, attributes a: [String : String] = [:]) {
        if name == "navPoint" {
            stack.append(TocNode(label: "", href: nil, children: []))
        } else if name == "content" {
            currentHref = a["src"]
        }
        currentText = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName qName: String?) {
        if name.lowercased() == "text" {
            if var last = stack.popLast() {
                last = TocNode(label: currentText.trimmingCharacters(in: .whitespacesAndNewlines), href: last.href, children: last.children)
                stack.append(last)
            }
        } else if name.lowercased() == "content" {
            if var last = stack.popLast() {
                last = TocNode(label: last.label, href: currentHref, children: last.children)
                stack.append(last)
            }
        } else if name.lowercased() == "navPoint" {
            let finished = stack.popLast()!
            if var parent = stack.popLast() {
                parent.children.append(finished)
                stack.append(parent)
            } else {
                roots.append(finished)
            }
        }
    }
}
