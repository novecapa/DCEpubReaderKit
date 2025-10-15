//
//  NavXHTMLParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

final class NavXHTMLParser: NSObject, XMLParserDelegate {
    private var collect = false
    private var stack: [TocNode] = []
    private(set) var roots: [TocNode] = []
    private var currentText = ""
    private var currentHref: String?
    
    func parse(navURL: URL) throws -> [TocNode] {
        let parser = XMLParser(contentsOf: navURL)!
        parser.delegate = self
        guard parser.parse() else {
            throw EpubError.parseError("nav.xhtml not valid")
        }
        return roots.isEmpty ? stack : roots
    }
    
    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName qName: String?, attributes a: [String : String] = [:]) {
        if name.lowercased() == "nav" {
            if (a["epub:type"]?.contains("toc") ?? false) || a["type"]?.contains("toc") == true {
                collect = true
            }
        }
        if collect && (name.lowercased() == "li") {
            stack.append(TocNode(label: "", href: nil, children: []))
        }
        if collect && name.lowercased() == "a" {
            currentHref = a["href"]
        }
        currentText = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName qName: String?) {
        let lower = name.lowercased()
        if collect && lower == "a" {
            if var last = stack.popLast() {
                let lbl = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                last = TocNode(label: lbl, href: currentHref, children: last.children)
                stack.append(last)
            }
        } else if collect && lower == "li" {
            let finished = stack.popLast()!
            if var parent = stack.popLast() {
                parent.children.append(finished)
                stack.append(parent)
            } else {
                roots.append(finished)
            }
        } else if lower == "nav" && collect {
            collect = false
        }
    }
}
