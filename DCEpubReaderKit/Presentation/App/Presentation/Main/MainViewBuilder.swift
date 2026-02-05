//
//  MainViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import Foundation

final class MainViewBuilder {
    func build() -> MainView {
        let viewModel = MainViewModel()
        let view = MainView(viewModel: viewModel)
        return view
    }
}
