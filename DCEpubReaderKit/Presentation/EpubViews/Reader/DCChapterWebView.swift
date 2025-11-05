//
//  ChapterWebView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 16/10/25.
//

import SwiftUI
import WebKit

enum DCChapterViewAction {
    case totalPageCount(count: Int, spineIndex: Int)
    case currentPage(index: Int, totalPages: Int, spineIndex: Int)
    case canTouch(enable: Bool)
    case coordsFirstNodeOfPage(orientation: DCBookrOrientation, spineIndex: Int, coords: String)
}

struct DCChapterWebView: UIViewRepresentable {

    @ObservedObject var viewModel: DCChapterWebViewModel

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = false
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.preferences.javaScriptEnabled = true

        let webView = DCWebView(frame: .zero, configuration: config)
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        webView.navigationDelegate = context.coordinator
        webView.scrollView.decelerationRate = .normal
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.allowsBackForwardNavigationGestures = false

        webView.scrollView.isPagingEnabled = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.bounces = false
        webView.scrollView.isDirectionalLockEnabled = true
        webView.scrollView.delegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isUserInteractionEnabled = true // (scrolling stays managed by TabView disable)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Avoid redundant loads using a tracker on the coordinator
        // (webView.url is unreliable with loadHTMLString)
        if context.coordinator.currentChapterURL != viewModel.chapterURL {
            let htmlContent = prepareHTMLString(pathtofile: viewModel.chapterURL.path)
            webView.loadHTMLString(htmlContent, baseURL: viewModel.chapterURL.deletingLastPathComponent())
            context.coordinator.currentChapterURL = viewModel.chapterURL
            UIView.animate(withDuration: DCChapterWebView.Coordinator.Constants.fadeDuration) { webView.alpha = 0 }
            viewModel.onAction(.canTouch(enable: false))
        }
        context.coordinator.readAccessURL = viewModel.readAccessURL
    }

    private func prepareHTMLString(pathtofile: String) -> String {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif

        guard let style = bundle.url(forResource: "Style", withExtension: "css"),
              let bridge = bundle.url(forResource: "Epub+Helper", withExtension: "js"),
              let dohighlight = bundle.url(forResource: "dohighlight", withExtension: "js"),
              let jquery = bundle.url(forResource: "jquery-1.10.2", withExtension: "js"),
              let jqueryhighlight = bundle.url(forResource: "jquery.highlight", withExtension: "js"),
              let utils = bundle.url(forResource: "EpubUtil", withExtension: "js"),
              let contentsOfFile = pathtofile.removingPercentEncoding,
              var htmlContent = try? String(contentsOfFile: contentsOfFile, encoding: .utf8) else {
            return ""
        }

        let headInject =
        """
        <link rel='stylesheet' type='text/css' href=\"\(style)\">\n
        <script type='text/javascript' src=\"\(bridge)\"></script>\n
        <script type='text/javascript' src=\"\(dohighlight)\"></script>\n
        <script type='text/javascript' src=\"\(jquery)\"></script>\n
        <script type='text/javascript' src=\"\(jqueryhighlight)\"></script>\n
        <script type='text/javascript' src=\"\(utils)\"></script>\n
        <meta name='viewport'
            content='width=device-width,
            height=device-height,
            initial-scale=1.0,
            maximum-scale=1.0,
            user-scalable=no'>\n
        </head>
        """

        htmlContent = htmlContent.replacingOccurrences(of: "</head>", with: headInject)

        let fontName = viewModel.userPreferences.getFontFamily().rawValue
        let fontSize = viewModel.userPreferences.getFontSize().rawValue
        let nightOrDayMode = viewModel.userPreferences.getDesktopMode().mode
        let classAttr = "class=\"\(fontName) \(fontSize) \(nightOrDayMode) mediaOverlayStyle0\""
        if htmlContent.range(of: "<html class=") == nil {
            htmlContent = htmlContent.replacingOccurrences(of: "<html", with: "<html \(classAttr)")
        }
        return htmlContent
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(spineIndex: viewModel.spineIndex,
                    userPreferences: viewModel.userPreferences,
                    onAction: viewModel.onAction)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {

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
            case coordsFirstNodeOfPage(page: Int)

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
                case .coordsFirstNodeOfPage(let page):
                    return "getCoordsFirstNodeOfPage(\(page))"
                }
            }
        }

        var totalPagesCache: Int?
        var currentChapterURL: URL?
        var readAccessURL: URL?
        private var scrollObserver: Any?
        weak var lazyWebView: DCWebView?

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
            await orientation == .horizontal ? applyHorizontalPagination(webView) : applyVerticalPagination(webView)
        }

        private func scrollToLastPageWihtOrientagtion(_ webView: WKWebView) async {
            await scrollAndReport(
                orientation == .horizontal ? .scrollToLastHorizontalPage : .scrollToLastVerticalPage,
                webView: webView
            )
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor [weak self] in
                guard let self else { return }

                if lazyWebView == nil,
                   let result = await applyPagination(webView),
                   let totalPages = Int(result) {
                    self.totalPagesCache = totalPages
                    self.onAction(.currentPage(index: 1,
                                               totalPages: totalPages,
                                               spineIndex: self.spineIndex))
                }

                if let target = note?.userInfo?[Constants.spineIndex] as? Int, target == self.spineIndex {
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

            // Allow file URLs (in-book navigation) as long as they're within readAccessURL
            if url.isFileURL {
                if let base = readAccessURL {
                    // Security: only allow URLs inside the allowed sandbox
                    if url.standardizedFileURL.path.hasPrefix(base.standardizedFileURL.path) {
                        decisionHandler(.allow); return
                    } else {
                        decisionHandler(.cancel); return
                    }
                } else {
                    decisionHandler(.allow); return
                }
            }

            // External links: open outside if enabled
            if opensExternalLinks, ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                #if os(iOS)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                #endif
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        private func updateCurrentPage(note: Notification?) {
            Task { @MainActor [weak self] in
                guard let self, let webView = self.lazyWebView else { return }
                if let target = note?.userInfo?[Constants.spineIndex] as? Int, target == self.spineIndex {
                    self.setInteractivity(false, on: webView, animated: true)
                    await self.scrollToLastPageWihtOrientagtion(webView)
                    self.note = nil
                    self.setInteractivity(true, on: webView, animated: true)
                }
                try? await Task.sleep(nanoseconds: Constants.settleDelay)
            }
        }
    }
}

// MARK: - Webview Scroll listener

extension DCChapterWebView.Coordinator: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update current page when the scroll settles
        let totalWebWidth = scrollView.contentSize.width
        let pageWidth = scrollView.frame.size.width
        guard pageWidth > 0 else { return }

        // Round to nearest to avoid off-by-one due to floating precision at boundaries
        let ratio = scrollView.contentOffset.x / pageWidth
        let zeroBasedIndex = Int(ratio.rounded())
        let cachedTotal = totalPagesCache ?? Int(ceil(totalWebWidth / pageWidth))

        // Clamp within 0..(cachedTotal-1)
        let clampedIndex = max(0, min(zeroBasedIndex, max(0, cachedTotal - 1)))
        let currentPageOneBased = clampedIndex + 1

        let totalPages = cachedTotal
        onAction(.currentPage(index: currentPageOneBased,
                              totalPages: totalPages,
                              spineIndex: spineIndex))

        Task { @MainActor in
            if let coords = await getCoordsFirstNodeOfPage(lazyWebView, currentPage: currentPageOneBased-1) {
                onAction(.coordsFirstNodeOfPage(orientation: .horizontal, spineIndex: spineIndex, coords: coords))
            }
        }
    }
}

// MARK: - DCChapterWebView.Coordinator JS Methods

private extension DCChapterWebView.Coordinator {
    func applyHorizontalPagination(_ webView: WKWebView) async -> String? {
        try? await webView.evaluateJavaScriptAsync(JSMethod.applyHorizontalPagination.rawValue) as? String
    }

    func applyVerticalPagination(_ webView: WKWebView) async -> String? {
        try? await webView.evaluateJavaScriptAsync(JSMethod.applyVerticalPagination.rawValue) as? String
    }

//    func scrollToLastHorizontalPage(_ webView: WKWebView) async {
//        await scrollAndReport(.scrollToLastHorizontalPage, webView: webView)
//    }
//
//    func scrollToLastVerticalPage(_ webView: WKWebView) async {
//        await scrollAndReport(.scrollToLastVerticalPage, webView: webView)
//    }

//    func scrollToFirstPage(_ webView: WKWebView) async {
//        await scrollAndReport(.scrollToFirstPage, webView: webView)
//    }

    func getCoordsFirstNodeOfPage(_ webView: DCWebView?, currentPage: Int) async -> String? {
        try? await webView?.evaluateJavaScriptAsync(
            JSMethod.coordsFirstNodeOfPage(page: currentPage).rawValue
        ) as? String
    }
}
