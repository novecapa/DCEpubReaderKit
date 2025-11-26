//
//  DCReaderView+Toolbar.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import SwiftUI

// MARK: Toolbar content DCReaderView

extension DCReaderView {
    @ToolbarContentBuilder
    var toolbarView: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .tint(.gray)
            }
        }
        ToolbarItem(placement: .principal) {
            Text(viewModel.bookTitle)
                .font(.system(size: 14))
                .foregroundStyle(viewModel.textColor)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button {
                    viewModel.saveBookMark()
                } label: {
                    Image(systemName: "bookmark")
                        .tint(.gray)
                }
                Button {
                    viewModel.showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                        .tint(.gray)
                }
            }
        }
    }
}

// MARK: Sheet DCReaderSettingsView

extension DCReaderView {
    var sheetSettingsView: some View {
        ZStack {
            viewModel.backgroundColor
                .ignoresSafeArea(edges: .all)
            DCReaderSettingsViewBuilder().build(
                fontSize: $viewModel.textSize,
                textFont: $viewModel.textFont,
                desktopMode: $viewModel.desktopMode,
                orientation: $viewModel.orientation,
                userPreferences: viewModel.userPreferences
            )
            .fixedSize(horizontal: false, vertical: true)
            .onHeightChange { height in
                viewModel.settingsSheetHeight = height
            }
            .presentationDetents([
                .height(
                    min(
                        max(viewModel.settingsSheetHeight + 1, 100),
                        UIScreen.main.bounds.height * 0.9
                    )
                )
            ])
            .presentationDragIndicator(.visible)
        }
    }
}
