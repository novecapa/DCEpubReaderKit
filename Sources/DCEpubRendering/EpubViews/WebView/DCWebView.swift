#if os(iOS)
//
//  DCWebView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 23/10/25.
//

import WebKit

final class DCWebView: WKWebView, WKScriptMessageHandler, UIGestureRecognizerDelegate {

    private enum Constants {
        static let selectionChanged = "selectionChanged"
    }

    var viewModel: DCWebViewModelProtocol!
    var selectionMenuTask: Task<Void, Never>?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setupBindings()
        injectSelectionListener()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBindings()
        injectSelectionListener()
    }

    deinit {
        teardown()
    }

    private func teardown() {
        selectionMenuTask?.cancel()
        self.configuration.userContentController.removeScriptMessageHandler(forName: Constants.selectionChanged)
    }

    private func setupBindings() {}

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    private func injectSelectionListener() {
        teardown()
        self.configuration.userContentController.add(self, name: Constants.selectionChanged)
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        selectionMenuTask?.cancel()

        let selectedText = (message.body as? [String: Any])?["text"] as? String
        guard let selectedText,
              selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            removeMenuItems()
            return
        }

        selectionMenuTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard Task.isCancelled == false else { return }
            await self?.shoMenuInteraction()
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

// MARK: - WKWebView evaluateJavaScript with async/await

extension WKWebView {
    @MainActor
    func evaluateJavaScriptAsync(_ javaScript: String) async throws -> String? {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String?, Error>) in
            self.evaluateJavaScript(javaScript) { result, error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: result as? String)
                }
            }
        }
    }
}
#endif
