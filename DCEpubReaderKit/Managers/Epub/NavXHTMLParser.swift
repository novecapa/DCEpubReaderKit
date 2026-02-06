//
//  NavXHTMLParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

/// Parses an EPUB3 navigation document (`nav.xhtml`) to build a hierarchical TOC.
/// It searches for the `<nav>` element that represents the table of contents
/// (typically marked with `epub:type="toc"`, `type="toc"`, or `role="doc-toc"`).
///
/// The expected structure is commonly:
/// ```html
/// <nav epub:type="toc">
///   <ol>
///     <li><a href="chapter1.xhtml">Chapter 1</a></li>
///     <li>
///       <a href="chapter2.xhtml">Chapter 2</a>
///       <ol>
///         <li><a href="chapter2-1.xhtml">Section 2.1</a></li>
///       </ol>
///     </li>
///   </ol>
/// </nav>
/// ```
///
/// This parser is defensive against variations:
/// - Accepts `epub:type="toc"`, `type="toc"`, or `role="doc-toc"`.
/// - Accumulates text across nested inline nodes (e.g., `<span>` inside `<a>`).
/// - Gracefully handles items without `<a>` (uses trimmed text as label if present).

final class NavXHTMLParser: NSObject, XMLParserDelegate {

    // MARK: - Public API

    /// Parses the given `nav.xhtml` file URL and returns the root TOC nodes.
    /// - Parameter navURL: URL to the EPUB3 navigation document.
    /// - Returns: Array of root `TocNode` items representing the TOC tree.
    /// - Throws: `EpubError.parseError` when the file cannot be parsed or no valid TOC is found.
    func parse(navURL: URL) throws -> [TocNode] {
        guard let parser = XMLParser(contentsOf: navURL) else {
            throw EpubError.parseError("Unable to initialize XMLParser for nav.xhtml")
        }

        // Reset state for each parse
        resetParsingState()

        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            throw EpubError.parseError("nav.xhtml is not a valid XML document")
        }

        // Prefer explicit roots if we built them; otherwise return whatever remained in the stack.
        let result = roots.isEmpty ? stack : roots
        if result.isEmpty {
            // No TOC collected at all — signal parse error for upstream handling.
            throw EpubError.parseError("No TOC <nav> found in nav.xhtml")
        }
        return result
    }

    // MARK: - Internal State

    private var isCollectingTOC = false
    private var stack: [TocNode] = []
    private var roots: [TocNode] = []

    private var currentText = ""
    private var currentHref: String?
    private var insideAnchorDepth = 0 // Tracks nested elements within <a> to know when the anchor truly ends.

    private func resetParsingState() {
        isCollectingTOC = false
        stack.removeAll(keepingCapacity: false)
        roots.removeAll(keepingCapacity: false)
        currentText = ""
        currentHref = nil
        insideAnchorDepth = 0
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser,
                didStartElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes: [String: String] = [:]) {

        let lower = name.lowercased()

        // Identify the TOC <nav>
        if lower == "nav", !isCollectingTOC {
            // Accept multiple conventions for marking the TOC <nav>
            let isTOC = (attributes["epub:type"]?.contains("toc") ?? false)
                || (attributes["type"]?.contains("toc") ?? false)
                || (attributes["role"]?.contains("doc-toc") ?? false)
                || ((attributes["id"]?.lowercased()) == "toc")

            if isTOC {
                isCollectingTOC = true
            }
        }

        guard isCollectingTOC else { return }

        // Start of a new list item
        if lower == "li" {
            stack.append(TocNode(label: "", href: nil, children: []))
            // Reset per-item buffers
            currentText = ""
            currentHref = nil
            insideAnchorDepth = 0
            return
        }

        // Anchor inside the TOC item
        if lower == "a" {
            currentHref = attributes["href"]
            insideAnchorDepth = 1
            currentText = ""
            return
        }

        // If we encounter nested elements within <a>, track depth so we only commit when the outermost </a> closes.
        if insideAnchorDepth > 0 {
            insideAnchorDepth += 1
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isCollectingTOC else { return }
        // Accumulate text both inside and (fallback) outside <a>
        currentText.append(string)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard isCollectingTOC, let text = String(data: CDATABlock, encoding: .utf8) else { return }
        currentText.append(text)
    }

    func parser(_ parser: XMLParser,
                didEndElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        let lower = name.lowercased()
        guard isCollectingTOC else { return }

        if lower == "a" {
            // Close the current anchor; commit label+href to the current (last) LI node.
            insideAnchorDepth = max(insideAnchorDepth - 1, 0)
            if insideAnchorDepth == 0 {
                let label = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !stack.isEmpty {
                    var last = stack.removeLast()
                    let href = currentHref
                    last = TocNode(label: label, href: href, children: last.children)
                    stack.append(last)
                }
                // Clear buffers related to the anchor
                currentText = ""
                currentHref = nil
            }
            return
        }

        if lower == "li" {
            // Finish this LI and attach it to its parent (if any), otherwise promote to root.
            guard let finished = stack.popLast() else { return }

            // If the LI ended without an <a>, but we accumulated text (e.g., <span>Title</span>), use it as label.
            if finished.label.isEmpty {
                let fallbackLabel = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !fallbackLabel.isEmpty {
                    let patched = TocNode(label: fallbackLabel, href: finished.href, children: finished.children)
                    attach(node: patched)
                } else {
                    attach(node: finished)
                }
            } else {
                attach(node: finished)
            }

            // Reset buffers for safety after closing an item
            currentText = ""
            currentHref = nil
            insideAnchorDepth = 0
            return
        }

        if lower == "nav" {
            // We reached the end of the TOC <nav>. Stop collecting further content.
            isCollectingTOC = false
            return
        }

        // If we close any element while inside an <a>, decrease depth.
        if insideAnchorDepth > 0 {
            insideAnchorDepth = max(insideAnchorDepth - 1, 0)
        }
    }

    // MARK: - Helpers

    private func attach(node: TocNode) {
        if var parent = stack.popLast() {
            parent.children.append(node)
            stack.append(parent)
        } else {
            roots.append(node)
        }
    }
}
