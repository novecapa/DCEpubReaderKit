//
//  EpubBook.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

public struct EpubBook {
    public let packagePath: String
    public let metadata: OPFMetadata
    public let manifest: [ManifestItem]
    public let spine: [SpineItem]
    public let toc: [TocNode]
    public let resourcesRoot: URL
}

// MARK: - Helpers to resolve absolute URLs for chapters and resources.

extension EpubBook {
    /// Directory that contains the OPF (root for manifest hrefs).
    /// Example: .../UnzippedBook/OEBPS/
    var opfDirectoryURL: URL {
        resourcesRoot
            .appendingPathComponent(packagePath)
            .deletingLastPathComponent()
            .standardizedFileURL
    }

    /// Absolute file URL for a manifest `href` (relative to OPF directory).
    func resourceURL(forHref href: String) -> URL {
        opfDirectoryURL
            .appendingPathComponent(href)
            .standardizedFileURL
    }

    /// Absolute file URL for a chapter referenced by spine index (via `idref` -> manifest item).
    func chapterURL(forSpineIndex index: Int) -> URL? {
        guard index >= 0 && index < spine.count else { return nil }
        let idref = spine[index].idref
        guard let item = manifest.first(where: { $0.id == idref }) else { return nil }
        return resourceURL(forHref: item.href)
    }

    /// Absolute file URL for a chapter by manifest `idref`.
    func chapterURL(forIdRef idref: String) -> URL? {
        guard let item = manifest.first(where: { $0.id == idref }) else { return nil }
        return resourceURL(forHref: item.href)
    }
}
