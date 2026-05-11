//
//  DCMarksViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 07/05/2026.
//

import SwiftUI
import DCEpubCore

@MainActor
final class DCMarksViewBuilder {
    func build(highlightsProvider: @escaping () async -> [DCHighlight],
               onSelect: @escaping (DCHighlight) -> Void) -> DCMarksView {
        let viewModel = DCMarksViewModel(
            highlightsProvider: highlightsProvider,
            onSelect: onSelect
        )
        return DCMarksView(viewModel: viewModel)
    }
}
