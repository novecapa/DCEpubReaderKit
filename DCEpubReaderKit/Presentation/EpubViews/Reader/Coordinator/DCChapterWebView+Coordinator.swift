//
//  DCChapterWebView+Coordinator.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 6/11/25.
//

import SwiftUI
import WebKit

extension DCChapterWebView {

    enum Constants {
        static let spineIndex = "spineIndex"
        static let fadeDuration: TimeInterval = 0.25
        static let settleDelay: UInt64 = 250_000_000
    }

    private enum JSMethod {
        case applyHorizontalPagination
        case applyVerticalPagination
        case scrollToLastHorizontalPage
        case scrollToLastVerticalPage
        case scrollToFirstPage
        case getCoordsFirstNodeOfPageHorizontal(page: Int)
        case getCoordsFirstNodeOfPageVertical(page: Int)
        case clearTextSelection

        var rawValue: String {
            switch self {
            case .applyHorizontalPagination:
                return "applyHorizontalPagination()"
            case .applyVerticalPagination:
                return "applyVerticalPagination()"
            case .scrollToLastHorizontalPage:
                return "scrollToLastHorizontalPage()"
            case .scrollToLastVerticalPage:
                return "scrollToLastVerticalPage()"
            case .scrollToFirstPage:
                return "scrollToFirstPage()"
            case .getCoordsFirstNodeOfPageHorizontal(let page):
                return "getCoordsFirstNodeOfPageHorizontal(\(page))"
            case .getCoordsFirstNodeOfPageVertical(let page):
                return "getCoordsFirstNodeOfPageVertical(\(page))"
            case .clearTextSelection:
                return "clearTextSelection()"
            }
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {

        var currentChapterURL: URL?
        var readAccessURL: URL?
        private var scrollObserver: Any?
        weak var lazyWebView: DCWebView?

        private var cachedTotalPages: Int = 0

        let opensExternalLinks: Bool
        let spineIndex: Int
        let userPreferences: DCUserPreferencesProtocol
        var note: Notification?
        let onAction: (DCChapterViewAction) -> Void

        init(opensExternalLinks: Bool = true,
             spineIndex: Int,
             userPreferences: DCUserPreferencesProtocol,
             onAction: @escaping (DCChapterViewAction) -> Void) {
            self.opensExternalLinks = opensExternalLinks
            self.spineIndex = spineIndex
            self.userPreferences = userPreferences
            self.onAction = onAction
            super.init()
            scrollObserver = NotificationCenter.default.addObserver(
                forName: .chapterShouldScrollToLastPage,
                object: nil,
                queue: .main
            ) { [weak self] note in
                guard let self else { return }
                self.note = note
                updateCurrentPage(note: note)
            }
        }

        deinit {
            if let scrollObserver {
                NotificationCenter.default.removeObserver(scrollObserver)
            }
        }

        private var orientation: DCBookrOrientation {
            userPreferences.getBookOrientation()
        }

        @MainActor
        private func setInteractivity(_ enabled: Bool, on webView: WKWebView?, animated: Bool = true) {
            guard let webView else { return }
            onAction(.canTouch(enable: enabled))
            let duration = animated ? Constants.fadeDuration : 0
            UIView.animate(withDuration: duration) {
                webView.alpha = enabled ? 1 : 0
            }
        }

        @MainActor
        private func scrollAndReport(_ method: JSMethod, webView: WKWebView) async {
            _ = try? await webView.evaluateJavaScriptAsync(method.rawValue)
            scrollViewDidEndDecelerating(webView.scrollView)
        }

        private func applyPagination(_ webView: WKWebView) async -> String? {
            await orientation == .horizontal ?
            applyHorizontalPagination(webView) :
            applyVerticalPagination(webView)
        }

        private func scrollToLastPageWihtOrientagtion(_ webView: WKWebView) async {
            await scrollAndReport(
                orientation == .horizontal ?.scrollToLastHorizontalPage : .scrollToLastVerticalPage,
                webView: webView
            )
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor [weak self] in
                guard let self else { return }

                if lazyWebView == nil,
                   let result = await applyPagination(webView),
                   let totalPages = Int(result) {
                    self.cachedTotalPages = max(1, totalPages)
                    self.onAction(.currentPage(index: 1,
                                               totalPages: self.cachedTotalPages,
                                               spineIndex: self.spineIndex))
                }

                if let target = note?.userInfo?[Constants.spineIndex] as? Int,
                   target == self.spineIndex {
                    await self.scrollToLastPageWihtOrientagtion(webView)
                    self.note = nil
                } else {
                    await self.scrollAndReport(.scrollToFirstPage, webView: webView)
                }

                try? await Task.sleep(nanoseconds: Constants.settleDelay)
                self.scrollViewDidEndDecelerating(webView.scrollView)

                self.lazyWebView = webView as? DCWebView
                self.setInteractivity(true, on: webView, animated: true)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel); return
            }
            if url.scheme == "highlight" {
                let decoded = url.absoluteString.removingPercentEncoding ?? ""
                if decoded == "" { return }

                let index = decoded.index(decoded.startIndex, offsetBy: 12)
                let highlightstring = decoded[..<index]
                let _ = NSCoder.cgRect(
                    for: decoded.replacingOccurrences(
                    of: highlightstring, with: "")
                )
                // Remove selected text
                removeSelectedText(lazyWebView)
                webView.evaluateJavaScript("getThisHighlight()") { (result, _) in
                    let highlightUUID = result as? String ?? ""
                    print("highlightID: \(highlightUUID)")
//                    let marktype = DCRBookMark.getHighlightType(bookId: self.bookid, uuid: highlightUUID)
//                    if marktype == DCRBookMark.kHighLight {
//                        self.webView.createHighlightMenu(rect: rect)
//                    } else if marktype == DCRBookMark.kNote   {
//                        self.webView.createNoteMenu(rect: rect)
//                    }
                }
            } else if url.scheme == "file" {}

            decisionHandler(.allow)
        }

        private func updateCurrentPage(note: Notification?) {
            Task { @MainActor [weak self] in
                guard let self, let webView = self.lazyWebView else { return }
                if let target = note?.userInfo?[Constants.spineIndex] as? Int, target == self.spineIndex {
                    self.setInteractivity(false, on: webView, animated: true)
                    try? await Task.sleep(nanoseconds: Constants.settleDelay)
                    await self.scrollToLastPageWihtOrientagtion(webView)
                    self.note = nil
                } else {
                    await self.scrollAndReport(.scrollToFirstPage, webView: webView)
                }
                try? await Task.sleep(nanoseconds: Constants.settleDelay)
                self.scrollViewDidEndDecelerating(webView.scrollView)
                self.setInteractivity(true, on: webView, animated: true)
            }
        }
    }
}

// MARK: - Webview Scroll listener

extension DCChapterWebView.Coordinator: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard orientation == .vertical else { return }
        let atTop = scrollView.contentOffset.y <= 0.0
        let visibleHeight = scrollView.bounds.size.height
        let contentHeight = scrollView.contentSize.height
        let atBottom = contentHeight > 0 && (scrollView.contentOffset.y + visibleHeight) >= (contentHeight - 1.0)

        // Threshold velocity to avoid accidental triggers
        let threshold: CGFloat = 0.5

        if atBottom && velocity.y > threshold {
            // Ask container to move to next chapter
            onAction(.navigateToNextChapter)
        } else if atTop && velocity.y < -threshold {
            // Ask container to move to previous chapter
            onAction(.navigateToPreviousChapter)
            updateCurrentPage(note: Notification(name: .chapterShouldScrollToLastPage,
                                                 userInfo: ["spineIndex": spineIndex]))
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isHorizontal = orientation == .horizontal
        let pageLength = isHorizontal ? scrollView.frame.size.width : scrollView.frame.size.height
        guard pageLength > 0 else { return }

        // Use JS-reported total pages when available to avoid rounding drift vs CSS sizing
        let contentLength = isHorizontal ? scrollView.contentSize.width : scrollView.contentSize.height
        // Include a tiny epsilon to avoid ceil jitter when the content length is extremely close to an exact multiple
        let computedTotal = Int(ceil(((contentLength / max(1, pageLength)) - 1e-6)))
        let totalPages = max(1, cachedTotalPages > 0 ? cachedTotalPages : computedTotal)

        // Normalize offset accounting for insets (on iOS, initial contentOffset can be -inset)
        let rawOffset = isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let insetTop = isHorizontal ? scrollView.adjustedContentInset.left : scrollView.adjustedContentInset.top
        let insetBottom = isHorizontal ? scrollView.adjustedContentInset.right : scrollView.adjustedContentInset.bottom
        let effectiveOffset = max(0, rawOffset + insetTop)

        // Indexing strategy:
        //  - Horizontal (paged): round to nearest page (snap)
        //  - Vertical (continuous): floor to the current page to avoid skipping ahead at half pages
        let zeroBased: Int
        if isHorizontal {
            zeroBased = Int((effectiveOffset / pageLength).rounded())
        } else {
            // epsilon to avoid bouncing rounding up when almost at the next page
            let epsilon: CGFloat = 0.0001
            zeroBased = Int(floor((effectiveOffset / pageLength) + epsilon))
        }

        var clampedZeroBased = min(max(0, zeroBased), max(0, totalPages - 1))

        // Strong clamp when at (or beyond) the bottom in vertical mode:
        if !isHorizontal {
            let visibleExtent = pageLength
            let nearBottom = (effectiveOffset + visibleExtent) >= (contentLength - insetBottom - 0.5)
            if nearBottom { clampedZeroBased = max(0, totalPages - 1) }
        }

        let currentPageOneBased = clampedZeroBased + 1

        onAction(.currentPage(index: currentPageOneBased,
                              totalPages: totalPages,
                              spineIndex: spineIndex))

        Task { @MainActor in
            if let coords = await getCoordsFirstNodeOfPage(lazyWebView, currentPage: currentPageOneBased) {
                onAction(.coordsFirstNodeOfPage(orientation: orientation, spineIndex: spineIndex, coords: coords))
            }
        }
    }
}

// MARK: - DCChapterWebView.Coordinator JS Methods

private extension DCChapterWebView.Coordinator {
    func applyHorizontalPagination(_ webView: WKWebView) async -> String? {
        try? await webView.evaluateJavaScriptAsync(
            DCChapterWebView.JSMethod.applyHorizontalPagination.rawValue
        ) as? String
    }

    func applyVerticalPagination(_ webView: WKWebView) async -> String? {
        try? await webView.evaluateJavaScriptAsync(
            DCChapterWebView.JSMethod.applyVerticalPagination.rawValue
        ) as? String
    }

    func getCoordsFirstNodeOfPage(_ webView: DCWebView?, currentPage: Int) async -> String? {
        let coordsFirstNodeOfPage = userPreferences.getBookOrientation() == .horizontal ?
        DCChapterWebView.JSMethod.getCoordsFirstNodeOfPageHorizontal :
        DCChapterWebView.JSMethod.getCoordsFirstNodeOfPageVertical
        return try? await webView?.evaluateJavaScriptAsync(
            coordsFirstNodeOfPage(currentPage).rawValue
        ) as? String
    }

    func removeSelectedText(_ webView: DCWebView?) {
        Task { @MainActor in
            _ = try? await webView?.evaluateJavaScriptAsync(
                DCChapterWebView.JSMethod.clearTextSelection.rawValue
            )
        }
    }
}
