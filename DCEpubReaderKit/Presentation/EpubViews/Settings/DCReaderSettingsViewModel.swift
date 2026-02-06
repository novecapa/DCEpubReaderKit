//
//  DCReaderSettingsViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import SwiftUI

final class DCReaderSettingsViewModel: ObservableObject {

    @Binding var fontSize: CGFloat
    @Binding var textFont: String
    @Binding var desktopMode: String
    @Binding var orientation: String

    let userPreferences: DCUserPreferencesProtocol

    init(fontSize: Binding<CGFloat>,
         textFont: Binding<String>,
         desktopMode: Binding<String>,
         orientation: Binding<String>,
         userPreferences: DCUserPreferencesProtocol) {
        self._fontSize = fontSize
        self._textFont = textFont
        self._desktopMode = desktopMode
        self._orientation = orientation
        self.userPreferences = userPreferences
    }

    var backgroundColor: Color {
        userPreferences.getDesktopMode().backgroundColor
    }

    var textColor: Color {
        userPreferences.getDesktopMode().textColor
    }
}
