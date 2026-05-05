//
//  DCWebView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 23/10/25.
//

import WebKit
import DCEpubCore

final class DCWebView: WKWebView, WKScriptMessageHandler, UIGestureRecognizerDelegate {

    private enum Constants {
        static let selectionChanged = "selectionChanged"
        static let highlightTapped  = "highlightTapped"
    }

    var viewModel: DCWebViewModelProtocol!
    var selectionMenuTask: Task<Void, Never>?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setupBindings()
        injectMessageHandlers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBindings()
        injectMessageHandlers()
    }

    deinit {
        teardown()
    }

    private func teardown() {
        selectionMenuTask?.cancel()
        configuration.userContentController.removeScriptMessageHandler(forName: Constants.selectionChanged)
        configuration.userContentController.removeScriptMessageHandler(forName: Constants.highlightTapped)
    }

    private func setupBindings() {}

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    private func injectMessageHandlers() {
        teardown()
        configuration.userContentController.add(self, name: Constants.selectionChanged)
        configuration.userContentController.add(self, name: Constants.highlightTapped)
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        switch message.name {
        case Constants.selectionChanged:
            handleSelectionChanged(message.body)
        case Constants.highlightTapped:
            handleHighlightTapped(message.body)
        default:
            break
        }
    }

    private func handleSelectionChanged(_ body: Any) {
        selectionMenuTask?.cancel()
        let selectedText = (body as? [String: Any])?["text"] as? String
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

    private func handleHighlightTapped(_ body: Any) {
        guard let dict = body as? [String: Any],
              let uuid = dict["uuid"] as? String,
              !uuid.isEmpty else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            let highlights = await self.viewModel.loadHighlights()
            guard let highlight = highlights.first(where: { $0.uuid == uuid }) else { return }

            if highlight.type == .note {
                self.showNoteOptionsAlert(highlight: highlight)
            } else {
                self.showDeleteHighlightAlert(uuid: uuid)
            }
        }
    }

    private func showNoteOptionsAlert(highlight: DCHighlight) {
        guard let vc = parentViewController else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit Note", style: .default) { [weak self] _ in
            self?.viewModel.showNoote(highlight: highlight)
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.viewModel.deleteHighlight(uuid: highlight.uuid)
                await self.removeHighlight(uuid: highlight.uuid)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }

    private func showDeleteHighlightAlert(uuid: String) {
        guard let vc = parentViewController else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Highlight", style: .destructive) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.viewModel.deleteHighlight(uuid: uuid)
                await self.removeHighlight(uuid: uuid)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }

    // MARK: - UIMenuController

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

// MARK: - Responder chain helper

private extension DCWebView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
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
