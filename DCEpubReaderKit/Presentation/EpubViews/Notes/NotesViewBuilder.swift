//
//  NotesViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 10/11/25.
//

import Foundation

final class NotesViewBuilder {
    func build(_ bookId: String,
               coords: String,
               chapterId: String) -> NotesView {
        let viewModel = NotesViewModel()
        let view = NotesView(viewModel: viewModel)
        return view
    }
}


final class NotesViewBuilderMock {
    func build(_ bookId: String = "",
               coords: String = "",
               chapterId: String = "") -> NotesView {
        let viewModel = NotesViewModel()
        let view = NotesView(viewModel: viewModel)
        return view
    }
}
