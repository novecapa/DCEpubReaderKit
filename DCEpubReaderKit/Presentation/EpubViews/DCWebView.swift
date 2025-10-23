//
//  DCWebView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 23/10/25.
//

import WebKit

final class DCWebView: WKWebView, WKScriptMessageHandler, UIGestureRecognizerDelegate {

    private enum JSMethod {
        case selectionChanged
        case rectsForSelection
        case getCoordsFromSelection
        case getSelectionString
        case highlight(type: HighlightType)

        var rawValue: String {
            switch self {
            case .selectionChanged:
                return "selectionChanged"
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

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setupTapGesture()
        injectSelectionListener()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTapGesture()
        injectSelectionListener()
    }

    deinit {
        teardown()
    }

    private func teardown() {
        self.configuration.userContentController.removeScriptMessageHandler(forName: JSMethod.selectionChanged.rawValue)
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeMenuItems))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func injectSelectionListener() {
        teardown()
        self.configuration.userContentController.add(self, name: JSMethod.selectionChanged.rawValue)
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        removeMenuItems()
        Task { @MainActor in
            await shoMenuInteraction()
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(applyHightLight) ||
            action == #selector(applyUnderline) {
            return true
        } else {
            return false
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}

// MARK: - DCWebView Highlight, Note

extension DCWebView {
    private func shoMenuInteraction() async {
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

    @objc private func removeMenuItems() {
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

    @objc private func applyHightLight() {
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

    @objc private func applyUnderline() {
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

// MARK: - WKWebView evaluateJavaScript with async/await

extension WKWebView {
    func evaluateJavaScriptAsync(_ javaScript: String) async throws -> Any? {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Any?, Error>) in
            self.evaluateJavaScript(javaScript) { result, error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: result)
                }
            }
        }
    }
}
