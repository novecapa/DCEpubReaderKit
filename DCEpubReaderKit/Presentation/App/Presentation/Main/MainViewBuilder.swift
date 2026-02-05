//
//  MainViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import Foundation

final class MainViewBuilder {
    func build() -> MainView {
        let database = BookFileDatabase()
        let repository = BookFileRepository(database: database)
        let useCase = BookFileUseCase(repository: repository)
        let viewModel = MainViewModel(useCase: useCase)
        let view = MainView(viewModel: viewModel)
        return view
    }
}
