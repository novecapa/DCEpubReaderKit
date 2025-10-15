//
//  EpubParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

struct EpubParser {

    static func parse(from unzipRoot: URL) throws -> EpubBook {
        // container.xml
        let container = ContainerXMLParser()
        let opfRelPath = try container.parse(url: unzipRoot)
        let opfURL = unzipRoot.appendingPathComponent(opfRelPath)
        guard FileManager.default.fileExists(atPath: opfURL.path) else { throw EpubError.missingOPF }
        
        // OPF → metadata, manifest, spine
        let opf = OPFParser()
        try opf.parse(opfURL: opfURL)
        
        // TOC → epub2 (ncx) or epub3 (nav.xhtml)
        let manifest = opf.manifest
        let opfDir = opfURL.deletingLastPathComponent()
        
        // epub2: item whith media-type = application/x-dtbncx+xml
        let ncxItem = manifest.first { $0.mediaType == "application/x-dtbncx+xml" }
        // epub3: item whith properties includes "nav"
        let navItem = manifest.first { ($0.properties ?? "").split(separator: " ").map(String.init).contains("nav") }
        
        var toc: [TocNode] = []
        if let ncx = ncxItem {
            let ncxURL = opfDir.appendingPathComponent(ncx.href)
            let p = NCXParser()
            toc = (try? p.parse(ncxURL: ncxURL)) ?? []
        } else if let nav = navItem {
            let navURL = opfDir.appendingPathComponent(nav.href)
            let p = NavXHTMLParser()
            toc = (try? p.parse(navURL: navURL)) ?? []
        }
        
        let book = EpubBook(
            version: opf.version,
            packagePath: opfRelPath,
            metadata: opf.metadata,
            manifest: manifest,
            spine: opf.spine,
            toc: toc,
            resourcesRoot: unzipRoot
        )
        return book
    }
}
