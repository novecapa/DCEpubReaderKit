//
//  DCReaderSettingsViewBuilder.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 31/10/25.
//

import SwiftUI

final class DCReaderSettingsViewBuilder {
    func build(fontSize: Binding<CGFloat>,
               textFont: Binding<String>,
               desktopMode: Binding<String>,
               orientation: Binding<String>,
               userPreferences: DCUserPreferencesProtocol) -> DCReaderSettingsView {
        let viewModel: DCReaderSettingsViewModel = DCReaderSettingsViewModel(fontSize: fontSize,
                                                                             textFont: textFont,
                                                                             desktopMode: desktopMode,
                                                                             orientation: orientation,
                                                                             userPreferences: userPreferences)
        let view: DCReaderSettingsView = DCReaderSettingsView(viewModel: viewModel)
        return view
    }
}
