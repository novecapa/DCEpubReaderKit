//
//  ChapterWebView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 16/10/25.
//

import SwiftUI
import WebKit

struct ChapterWebView: UIViewRepresentable {

    /// Absolute file URL of the HTML/XHTML chapter.
    let chapterURL: URL

    /// Directory granting read access to all relative resources (usually `opfDirectoryURL`).
    let readAccessURL: URL

    /// Whether to allow opening external HTTP/HTTPS links outside the web view.
    var opensExternalLinks: Bool = true

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

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Avoid redundant loads.
        if webView.url != chapterURL {
            // LOAD from url path: webView.loadFileURL(chapterURL, allowingReadAccessTo: readAccessURL)
            let HTMLContent = prepareHTMLString(pathtofile: chapterURL.path)
            webView.loadHTMLString(HTMLContent, baseURL: chapterURL.deletingLastPathComponent())
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

        if let style = bundle.url(forResource: "Style", withExtension: "css"),
           let utils = bundle.url(forResource: "EpubUtil", withExtension: "js") {

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
            var HTMLContent = try? String(contentsOfFile: pathtofile, encoding: .utf8)
            HTMLContent = HTMLContent?.replacingOccurrences(of: "</head>", with: headInject)

            let fontName = "original"
            let fontSize = "textSizeFive"
            let nightOrDayMode = "" // nightMode
            HTMLContent = HTMLContent?.replacingOccurrences(
                of: "<html",
                with: "<html class=\"\(fontName) \(fontSize) \(nightOrDayMode) mediaOverlayStyle0'"
            )
            return HTMLContent ?? ""
        }
        return ""
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var opensExternalLinks: Bool = true
        var readAccessURL: URL?

        // Dentro de Coordinator
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("applyHorizontalPagination()") { _, _ in
                print("-> applyHorizontalPagination()")
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

extension ChapterWebView.Coordinator {
    func nextPage(_ webView: WKWebView) {
        webView.evaluateJavaScript("EPUBUtil.next()")
    }

    func prevPage(_ webView: WKWebView) {
        webView.evaluateJavaScript("EPUBUtil.prev()")
    }

    func currentPageIndex(_ webView: WKWebView, completion: @escaping (Int) -> Void) {
        webView.evaluateJavaScript("EPUBUtil.pageIndex()") { value, _ in
            completion(value as? Int ?? 0)
        }
    }
}
