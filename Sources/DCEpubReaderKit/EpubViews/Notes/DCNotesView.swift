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
                        .tint(Color(.backgroundNight))
                }
                Spacer()
                Text("Notes - Book title")
                    .font(.system(size: 14))
                    .tint(Color(.backgroundNight))
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
    DCNotesViewBuilderMock().build()
}
