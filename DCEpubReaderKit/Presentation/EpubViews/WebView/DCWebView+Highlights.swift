//
//  DCWebView+Highlights.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 24/10/25.
//

import WebKit

// MARK: - DCWebView Highlights

extension DCWebView {

    private enum JSMethod {
        case rectsForSelection
        case getCoordsFromSelection
        case getSelectionString
        case highlight(type: HighlightType)

        var rawValue: String {
            switch self {
            case .rectsForSelection:
                return "rectsForSelection()"
            case .getCoordsFromSelection:
                return "getCoordsFromSelection()"
            case .getSelectionString:
                return "window.getSelection().toString()"
            case .highlight(type: let type):
                return "highlightString('highlight-\(type.rawValue)')"
            }
        }
    }

    private enum HighlightType: String {
        case yellow
        case underline
    }

    func shoMenuInteraction() async {
        guard let selected = await getSelectedText(),
              let rectsString = await getRectsFromSelection(),
              let rectsData = rectsString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: rectsData) as? [[String: Any]],
              let first = jsonArray.first,
              let xValue = first["x"] as? CGFloat,
              let yValue = first["y"] as? CGFloat else { return }
        let rectInView = CGRect(x: xValue, y: yValue, width: 0, height: 0)
        self.presentSelectionMenu(at: rectInView, text: selected)
    }

    private func presentSelectionMenu(at rect: CGRect, text: String) {
        removeMenuItems()
        let menu = UIMenuController.shared
        menu.menuItems = [
            UIMenuItem(title: "Highlight", action: #selector(applyHightLight)),
            UIMenuItem(title: "Note", action: #selector(applyUnderline))
        ]
        menu.showMenu(from: self, rect: rect)
    }

    @objc func removeMenuItems() {
        let menu = UIMenuController.shared
        menu.menuItems?.removeAll()
        menu.hideMenu()
        menu.menuItems = nil
    }

    private func getRectsFromSelection() async -> String? {
        try? await self.evaluateJavaScriptAsync(JSMethod.rectsForSelection.rawValue) as? String
    }

    private func getCoordsFromSelection() async -> String? {
        try? await self.evaluateJavaScriptAsync(JSMethod.getCoordsFromSelection.rawValue) as? String
    }

    private func getSelectedText() async -> String? {
        try? await self.evaluateJavaScriptAsync(JSMethod.getSelectionString.rawValue) as? String
    }

    private func highlightSelection(type: HighlightType) async -> String? {
        try? await self.evaluateJavaScriptAsync(JSMethod.highlight(type: type).rawValue) as? String
    }

    @objc func applyHightLight() {
        Task { @MainActor in
            guard let coords = await getCoordsFromSelection(),
                  let selectedText = await getSelectedText(),
                  !selectedText.contains("\n"),
                  let uuid = await highlightSelection(type: .yellow) else {
                return
            }
            print(
                "coords: \(coords) text: \(selectedText) uuid: \(uuid)"
            )
            self.removeMenuItems()
        }
    }

    @objc func applyUnderline() {
        Task { @MainActor in
            guard let coords = await getCoordsFromSelection(),
                  let selectedText = await getSelectedText(),
                  !selectedText.contains("\n"),
                  let uuid = await highlightSelection(type: .underline) else {
                return
            }
            print(
                "coords: \(coords) text: \(selectedText) uuid: \(uuid)"
            )
            self.removeMenuItems()
        }
    }
}
