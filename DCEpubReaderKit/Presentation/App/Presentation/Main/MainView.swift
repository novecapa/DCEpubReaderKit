//
//  MainView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import SwiftUI

struct MainView: View {

    @ObservedObject var viewModel: MainViewModel

    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
            }
            .navigationTitle("My Library".localized())
            .toolbar {
                // Button("Import EPUB".localized()) { isPickerPresented = true }
            }
            .onAppear {
                viewModel.loadBooks()
            }
        }
    }
}

#Preview {
    MainViewBuilder().build()
}
