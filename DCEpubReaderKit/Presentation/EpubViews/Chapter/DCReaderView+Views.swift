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
            Text(bookTitle)
                .font(.system(size: 14))
                .foregroundStyle(textColor)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gear")
                    .tint(.gray)
            }
        }
    }
}

// MARK: Sheet DCReaderSettingsView

extension DCReaderView {
    var sheetSettingsView: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea(edges: .all)
            DCReaderSettingsView(
                fontSize: $textSize,
                textFont: $textFont,
                desktopMode: $desktopMode,
                userPreferences: userPreferences
            )
            .fixedSize(horizontal: false, vertical: true)
            .onHeightChange { height in
                settingsSheetHeight = height
            }
            .presentationDetents([
                .height(
                    min(
                        max(settingsSheetHeight + 1, 100),
                        UIScreen.main.bounds.height * 0.9
                    )
                )
            ])
            .presentationDragIndicator(.visible)
        }
    }
}
