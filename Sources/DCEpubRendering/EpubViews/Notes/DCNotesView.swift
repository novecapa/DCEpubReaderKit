//
//  DCNotesView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 10/11/25.
//

import SwiftUI

struct DCNotesView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DCNotesViewModel

    init(viewModel: DCNotesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(viewModel.textColor)
                }
                Spacer()
                Text("Notes")
                    .font(.system(size: 15))
                    .foregroundStyle(viewModel.textColor)
                EmptyView()
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            TextEditor(text: $viewModel.note)
                .scrollContentBackground(.hidden)
                .background(viewModel.backgroundColor.opacity(0.6))
                .cornerRadius(16)
                .padding(16)
                .foregroundStyle(viewModel.textColor)
                .onChange(of: viewModel.note) { newNote in
                    viewModel.noteDidChange(newNote)
                }
        }
        .background(viewModel.backgroundColor)
    }
}

#if DEBUG

#Preview {
    DCNotesViewBuilderMock().build()
}

#endif
