//
//  NotesViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 10/11/25.
//

import Foundation

final class DCNotesViewBuilder {
    func build(_ bookId: String,
               coords: String,
               chapterId: String) -> DCNotesView {
        let viewModel = DCNotesViewModel()
        let view = DCNotesView(viewModel: viewModel)
        return view
    }
}

final class DCNotesViewBuilderMock {
    func build(_ bookId: String = "",
               coords: String = "",
               chapterId: String = "") -> DCNotesView {
        let viewModel = DCNotesViewModel()
        let view = DCNotesView(viewModel: viewModel)
        return view
    }
}
