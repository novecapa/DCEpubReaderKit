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

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setupBindings()
        setupTapGesture()
        injectSelectionListener()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBindings()
        setupTapGesture()
        injectSelectionListener()
    }

    deinit {
        teardown()
    }

    private func teardown() {
        self.configuration.userContentController.removeScriptMessageHandler(forName: Constants.selectionChanged)
    }

    private func setupBindings() {}

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
        self.configuration.userContentController.add(self, name: Constants.selectionChanged)
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        removeMenuItems()
        Task { @MainActor [weak self] in
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

protocol DCWebViewModelProtocol {
    func showNoote()
    var refresh: (() -> Void)? { get set }
}

protocol DCWebViewRouterProtocol {
    func showNoote()
}

final class DCWebViewModel: DCWebViewModelProtocol {

    var refresh: (() -> Void)?

    private let router: DCWebViewRouterProtocol

    init(router: DCWebViewRouterProtocol) {
        self.router = router
    }

    func showNoote() {
        router.showNoote()
    }
}

final class DCWebViewBuilder {
    func build(frame: CGRect,
               configuration: WKWebViewConfiguration,
               router: DCWebViewRouterProtocol) -> DCWebView {
        let viewModel = DCWebViewModel(router: router)
        let view = DCWebView(frame: frame, configuration: configuration)
        view.viewModel = viewModel
        return view
    }
}
