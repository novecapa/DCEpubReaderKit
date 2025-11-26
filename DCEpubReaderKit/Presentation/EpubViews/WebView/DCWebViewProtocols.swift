//
//  DCWebViewProtocols.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/11/25.
//

import Foundation

protocol DCWebViewModelProtocol {
    func showNoote()
    var refresh: (() -> Void)? { get set }
}

protocol DCWebViewRouterProtocol {
    func showNoote()
}
