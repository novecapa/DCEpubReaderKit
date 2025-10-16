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
    // MARK: Paths

    /// Directory that contains the OPF (base directory for all manifest hrefs).
    /// Example: .../UnzippedBook/OEBPS/
    var opfDirectoryURL: URL {
        resourcesRoot
            .appendingPathComponent(packagePath)
            .deletingLastPathComponent()
            .standardizedFileURL
    }

    /// Returns the absolute file URL for a manifest `href` (relative to the OPF directory).
    func resourceURL(forHref href: String) -> URL {
        opfDirectoryURL
            .appendingPathComponent(href)
            .standardizedFileURL
    }

    // MARK: Chapters

    /// Returns the absolute URL for a chapter by spine index.
    public func chapterURL(forSpineIndex index: Int) -> URL? {
        guard index >= 0 && index < spine.count else { return nil }
        let idref = spine[index].idref
        guard let item = manifest.first(where: { $0.id == idref }) else { return nil }
        return resourceURL(forHref: item.href)
    }

    /// Returns the absolute URL for a chapter by manifest `idref`.
    public func chapterURL(forIdRef idref: String) -> URL? {
        guard let item = manifest.first(where: { $0.id == idref }) else { return nil }
        return resourceURL(forHref: item.href)
    }

    // MARK: TOC ↔ Spine correlation

    /// Finds the TOC node that corresponds to a given spine `idref`.
    /// Strategy:
    /// 1) Resolve the manifest item by `idref` to get its `href` (e.g., "Text/chapter10.xhtml").
    /// 2) Search the TOC tree for the first node whose `href` (without fragment) either:
    ///    - contains the manifest href (case-insensitive),
    ///    - contains the last path component of the manifest href,
    ///    - or contains the `idref` itself.
    public func tocNode(forSpineIdRef idref: String) -> TocNode? {
        guard let manifestItem = manifest.first(where: { $0.id == idref }) else { return nil }
        let targetHref = manifestItem.href
        let targetNoFrag = dropFragment(targetHref)
        let targetLower = targetNoFrag.lowercased()
        let targetLastLower = lastPathComponent(targetNoFrag).lowercased()

        return findInTOC(toc, matching: { node in
            guard let nodeHref = node.href?.lowercased(), !nodeHref.isEmpty else { return false }
            let nodeNoFrag = dropFragment(nodeHref)
            return nodeNoFrag.contains(targetLower)
                || nodeNoFrag.contains(targetLastLower)
                || nodeNoFrag.contains(idref.lowercased())
        })
    }

    /// Returns a human-friendly chapter title for a `spine idref`, if available from the TOC.
    public func chapterTitle(forSpineIdRef idref: String) -> String? {
        return tocNode(forSpineIdRef: idref)?.label
    }

    /// Returns a human-friendly chapter title for a `spine` index.
    public func chapterTitle(forSpineIndex index: Int) -> String? {
        guard index >= 0 && index < spine.count else { return nil }
        return chapterTitle(forSpineIdRef: spine[index].idref)
    }

    /// Resolves a TOC `href` (may include a fragment) to a `spine` index, if possible.
    public func spineIndex(forTOCHref href: String?) -> Int? {
        guard let href, !href.isEmpty else { return nil }

        // Normalize target
        let targetNoFrag = dropFragment(href)
        let targetLower = targetNoFrag.lowercased()
        let targetLastLower = lastPathComponent(targetNoFrag).lowercased()

        // Build a lookup of (idref, normalizedHref, lastComponentLower)
        let hrefByIdref: [(idref: String, hrefLower: String, lastLower: String)] = spine.compactMap { item in
            guard let mi = manifest.first(where: { $0.id == item.idref }) else { return nil }
            let hNoFrag = dropFragment(mi.href)
            return (item.idref, hNoFrag.lowercased(), lastPathComponent(hNoFrag).lowercased())
        }

        // 1) Contains match between normalized full paths (both directions)
        if let match = hrefByIdref.first(where: { pair in
            targetLower.contains(pair.hrefLower) || pair.hrefLower.contains(targetLower)
        }) {
            return spine.firstIndex(where: { $0.idref == match.idref })
        }

        // 2️⃣ Last path component match
        if let match = hrefByIdref.first(where: { pair in
            pair.lastLower == targetLastLower
                || targetLastLower.contains(pair.lastLower)
                || pair.lastLower.contains(targetLastLower)
        }) {
            return spine.firstIndex(where: { $0.idref == match.idref })
        }

        // 3) Fallback: `idref` occurrence within the target href
        if let match = hrefByIdref.first(where: { pair in
            targetLower.contains(pair.idref.lowercased())
        }) {
            return spine.firstIndex(where: { $0.idref == match.idref })
        }

        return nil
    }

    // MARK: - Private helpers

    /// Depth-first search over a TOC tree using a predicate.
    private func findInTOC(_ nodes: [TocNode], matching predicate: (TocNode) -> Bool) -> TocNode? {
        for node in nodes {
            if predicate(node) { return node }
            if let found = findInTOC(node.children, matching: predicate) {
                return found
            }
        }
        return nil
    }

    /// Returns `href` without a trailing `#fragment`.
    private func dropFragment(_ href: String) -> String {
        if let idx = href.firstIndex(of: "#") {
            return String(href[..<idx])
        }
        return href
    }

    /// Returns the last path component of an `href`-like string.
    private func lastPathComponent(_ href: String) -> String {
        if let comp = URL(string: href)?.lastPathComponent, !comp.isEmpty {
            return comp
        }
        return href.split(separator: "/").last.map(String.init) ?? href
    }
}
