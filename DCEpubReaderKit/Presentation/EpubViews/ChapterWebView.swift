//
//  ChapterWebView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 16/10/25.
//

import SwiftUI
import WebKit

enum ChapterViewAction {
    case totalPageCount(count: Int, spineIndex: Int)
    case currentPage(index: Int, spineIndex: Int)
}

struct ChapterWebView: UIViewRepresentable {

    /// Absolute file URL of the HTML/XHTML chapter.
    let chapterURL: URL

    /// Directory granting read access to all relative resources (usually `opfDirectoryURL`).
    let readAccessURL: URL

    /// Whether to allow opening external HTTP/HTTPS links outside the web view.
    let opensExternalLinks: Bool

    /// Index of the spine that this view represents (used for disambiguating async callbacks).
    let spineIndex: Int

    let onAction: (ChapterViewAction) -> Void

    init(chapterURL: URL,
         readAccessURL: URL,
         opensExternalLinks: Bool,
         spineIndex: Int,
         onAction: @escaping (ChapterViewAction) -> Void) {
        self.chapterURL = chapterURL
        self.readAccessURL = readAccessURL
        self.opensExternalLinks = opensExternalLinks
        self.spineIndex = spineIndex
        self.onAction = onAction
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = false
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.preferences.javaScriptEnabled = true

        let webView = WKWebView(frame: .zero, configuration: config)
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
        webView.alpha = 0

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Avoid redundant loads using a tracker on the coordinator
        // (webView.url is unreliable with loadHTMLString)
        if context.coordinator.currentChapterURL != chapterURL {
            let htmlContent = prepareHTMLString(pathtofile: chapterURL.path)
            webView.loadHTMLString(htmlContent, baseURL: chapterURL.deletingLastPathComponent())
            context.coordinator.currentChapterURL = chapterURL
        }
        context.coordinator.opensExternalLinks = opensExternalLinks
        context.coordinator.readAccessURL = readAccessURL
    }

    private func prepareHTMLString(pathtofile: String) -> String {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif

        guard let style = bundle.url(forResource: "Style", withExtension: "css"),
              let utils = bundle.url(forResource: "EpubUtil", withExtension: "js"),
              let contentsOfFile = pathtofile.removingPercentEncoding,
              var htmlContent = try? String(contentsOfFile: contentsOfFile, encoding: .utf8) else {
            return ""
        }

        let headInject =
        """
        <link rel='stylesheet' type='text/css' href=\"\(style)\">\n
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

        // TODO: Get config from preferences
        let fontName = "original"
        let fontSize = "textSizeSeven"
        let nightOrDayMode = "" // nightMode
        htmlContent = htmlContent.replacingOccurrences(
            of: "<html",
            with: "<html class=\"\(fontName) \(fontSize) \(nightOrDayMode) mediaOverlayStyle0'"
        )
        return htmlContent
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(spineIndex: spineIndex, onAction: onAction)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {

        var opensExternalLinks: Bool
        var readAccessURL: URL?
        var currentChapterURL: URL?
        let onAction: (ChapterViewAction) -> Void
        let spineIndex: Int
        weak var lazyWebview: WKWebView?

        init(opensExternalLinks: Bool = true,
             readAccessURL: URL? = nil,
             spineIndex: Int,
             onAction: @escaping (ChapterViewAction) -> Void) {
            self.opensExternalLinks = opensExternalLinks
            self.readAccessURL = readAccessURL
            self.spineIndex = spineIndex
            self.onAction = onAction
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task {
                if let result = await applyHorizontalPagination(webView),
                   let pageCount = Int(result) {
                    self.onAction(.totalPageCount(count: pageCount, spineIndex: self.spineIndex))
                }
                withAnimation {
                    webView.alpha = 1
                }
                lazyWebview = webView
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
    }
}

// MARK: - Webview Scroll listener

extension ChapterWebView.Coordinator: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update current page when the scroll settles
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }

        // Use floor so exact boundaries map to the correct zero-based page index
        let zeroBasedIndex = Int(floor(scrollView.contentOffset.x / pageWidth))
        let currentPageOneBased = zeroBasedIndex + 1

        onAction(.currentPage(index: currentPageOneBased, spineIndex: spineIndex))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let pageWidth = scrollView.bounds.width
            guard pageWidth > 0 else { return }
            let zeroBasedIndex = Int(floor(scrollView.contentOffset.x / pageWidth))
            let currentPageOneBased = zeroBasedIndex + 1
            onAction(.currentPage(index: currentPageOneBased, spineIndex: spineIndex))
        }
    }
}

// MARK: - ChapterWebView.Coordinator JS Methods

extension ChapterWebView.Coordinator {
    func applyHorizontalPagination(_ webView: WKWebView) async -> String? {
        try? await webView.evaluateJavaScriptAsync("applyHorizontalPagination()") as? String
    }

    func scrollToLastPage(_ webView: WKWebView) async {
        _ = try? await webView.evaluateJavaScriptAsync("scrollToLastHorizontalPage()")
    }
}

// MARK: - WKWebView evaluateJavaScript with async/await

private extension WKWebView {
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
