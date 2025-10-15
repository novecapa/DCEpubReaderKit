//
//  NCXParser.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

/// Parses an EPUB2 NCX (`.ncx`) table of contents into a tree of `TocNode`.
/// Expected structure (simplified):
/// ```xml
/// <ncx>
///   <navMap>
///     <navPoint id="...">
///       <navLabel><text>Chapter 1</text></navLabel>
///       <content src="chapter1.xhtml"/>
///       <navPoint>...</navPoint> <!-- children -->
///     </navPoint>
///   </navMap>
/// </ncx>
/// ```
///
/// Robustness notes:
/// - Handles nested `navPoint` nodes via a stack to build hierarchy.
/// - Collects text inside `<navLabel><text>…</text></navLabel>` (accumulates mixed/CDATA).
/// - Reads `href` from `<content src=\"…\"/>`.
/// - Ignores case by lowercasing element names.
/// - Defensive against malformed NCX (returns empty list or throws on parser init/parse error).

final class NCXParser: NSObject, XMLParserDelegate {

    // MARK: - Public API

    /// Parses the given NCX file URL and returns the root TOC nodes.
    /// - Parameter ncxURL: URL to the `.ncx` file.
    /// - Returns: Array of root `TocNode` items representing the TOC tree.
    /// - Throws: `EpubError.parseError` when the file cannot be parsed or the XML is invalid.
    func parse(ncxURL: URL) throws -> [TocNode] {
        guard let parser = XMLParser(contentsOf: ncxURL) else {
            throw EpubError.parseError("Unable to initialize XMLParser for NCX")
        }

        // Reset state before each parse
        resetParsingState()

        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            throw EpubError.parseError("NCX is not a valid XML document")
        }

        return roots
    }

    // MARK: - Internal State

    private var stack: [TocNode] = []
    private(set) var roots: [TocNode] = []

    private var currentText = ""
    private var collectingLabelText = false

    private func resetParsingState() {
        stack.removeAll(keepingCapacity: false)
        roots.removeAll(keepingCapacity: false)
        currentText = ""
        collectingLabelText = false
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser,
                didStartElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes: [String: String] = [:]) {

        let lower = name.lowercased()

        switch lower {
        case "navpoint":
            // Begin a new TOC node
            stack.append(TocNode(label: "", href: nil, children: []))

        case "content":
            // Attach href to current top node (if any)
            if let src = attributes["src"], var last = stack.popLast() {
                last = TocNode(label: last.label, href: src, children: last.children)
                stack.append(last)
            }

        case "navlabel":
            // Following <text> belongs to the current node's label
            collectingLabelText = true
            currentText = ""

        case "text":
            if collectingLabelText {
                // Prepare to accumulate text content
                // (we also reset in navLabel start, but guard here for safety)
                currentText = ""
            }

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard collectingLabelText else { return }
        currentText.append(string)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard collectingLabelText, let text = String(data: CDATABlock, encoding: .utf8) else { return }
        currentText.append(text)
    }

    func parser(_ parser: XMLParser,
                didEndElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        let lower = name.lowercased()

        switch lower {
        case "text":
            // End of a label's text – assign to the current node (do not close navLabel yet)
            if collectingLabelText, let last = stack.popLast() {
                let label = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                let patched = TocNode(label: label, href: last.href, children: last.children)
                stack.append(patched)
                currentText = ""
            }

        case "navlabel":
            // Completed label collection
            collectingLabelText = false
            currentText = ""

        case "navpoint":
            // Close current node; attach to parent or promote to root
            guard let finished = stack.popLast() else { return }
            if var parent = stack.popLast() {
                parent.children.append(finished)
                stack.append(parent)
            } else {
                roots.append(finished)
            }

        default:
            break
        }
    }
}
