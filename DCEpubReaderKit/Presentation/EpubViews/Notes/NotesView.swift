//
//  NotesView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 10/11/25.
//

import SwiftUI

struct NotesView: View {

    @ObservedObject var viewModel: NotesViewModel

    init(viewModel: NotesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            HStack {
                Button {
                    // TODO: --
                } label: {
                    Image(systemName: "xmark")
                        .tint(.backgroundNight)
                }
                Spacer()
                Text("Notes - Book title")
                    .font(.system(size: 14))
                    .tint(.backgroundNight)
                EmptyView()
                Spacer()
            }
            .padding(.horizontal, 16)
            TextEditor(text: $viewModel.note)
                .cornerRadius(16)
                .padding(16)
                .background(.gray)
        }
    }
}

#Preview {
    NotesViewBuilderMock().build()
}
