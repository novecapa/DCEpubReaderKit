//
//  DCMarksViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 07/05/2026.
//

import Foundation
import DCEpubCore

@MainActor
final class DCMarksViewModel: ObservableObject {

    @Published var selectedType: DCHighlight.MarkType = .highlight
    @Published private(set) var highlights: [DCHighlight] = []

    private let highlightsProvider: () async -> [DCHighlight]
    private let onSelect: (DCHighlight) -> Void

    init(highlightsProvider: @escaping () async -> [DCHighlight],
         onSelect: @escaping (DCHighlight) -> Void) {
        self.highlightsProvider = highlightsProvider
        self.onSelect = onSelect
    }

    var filteredHighlights: [DCHighlight] {
        highlights.filter { $0.type == selectedType }
    }

    func loadIfNeeded() async {
        guard highlights.isEmpty else { return }
        highlights = await highlightsProvider()
    }

    func didSelect(_ highlight: DCHighlight) {
        onSelect(highlight)
    }
}
