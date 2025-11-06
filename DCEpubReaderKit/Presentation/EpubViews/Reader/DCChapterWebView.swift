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
    case navigateToNextChapter
    case navigateToPreviousChapter
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
        webView.scrollView.alwaysBounceVertical = viewModel.userPreferences.getBookOrientation() == .vertical
        webView.scrollView.bounces = viewModel.userPreferences.getBookOrientation() == .vertical
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
            UIView.animate(
                withDuration: DCChapterWebView.Constants.fadeDuration
            ) {
                webView.alpha = 0
            }
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
              let epubHelper = bundle.url(forResource: "EpubHelper", withExtension: "js"),
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
        <script type='text/javascript' src=\"\(epubHelper)\"></script>\n
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
}
