//
//  DCWebViewProtocols.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/11/25.
//

import Foundation
import DCEpubCore

@MainActor
protocol DCWebViewModelProtocol {
    func showNoote()
    func saveHighlight(_ highlight: DCHighlight) async
    func loadHighlights() async -> [DCHighlight]
    func deleteHighlight(uuid: String) async
    var currentBookId: String { get }
    var currentChapterId: String { get }
    var currentSpineIndex: Int { get }
    var refresh: (() -> Void)? { get set }
}

@MainActor
protocol DCWebViewRouterProtocol {
    func showNoote()
    func saveHighlight(_ highlight: DCHighlight) async
    func loadHighlights() async -> [DCHighlight]
    func deleteHighlight(uuid: String) async
    var currentBookId: String { get }
    var currentChapterId: String { get }
    var currentSpineIndex: Int { get }
}
