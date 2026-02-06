//
//  DCWebViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/11/25.
//

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
