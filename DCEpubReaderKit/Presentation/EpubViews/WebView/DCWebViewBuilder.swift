//
//  DCWebViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/11/25.
//

import WebKit

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
