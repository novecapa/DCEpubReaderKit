//
//  DCReaderSettingsView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import SwiftUI

struct DCReaderSettingsView: View {

    @Binding var fontSize: CGFloat
    @Binding var textFont: String
    @Binding var desktopMode: String
    @Binding var orientation: String

    private let userPreferences: DCUserPreferencesProtocol

    init(fontSize: Binding<CGFloat>,
         textFont: Binding<String>,
         desktopMode: Binding<String>,
         orientation: Binding<String>,
         userPreferences: DCUserPreferencesProtocol = DCUserPreferences(userPreferences: UserDefaults.standard)) {
        self._fontSize = fontSize
        self._textFont = textFont
        self._desktopMode = desktopMode
        self._orientation = orientation
        self.userPreferences = userPreferences
    }

    private var backgroundColor: Color {
        userPreferences.getDesktopMode().backgroundColor
    }

    private var textColor: Color {
        userPreferences.getDesktopMode().textColor
    }

    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("A")
                        .frame(height: 54)
                        .font(.system(size: 13))
                        .foregroundStyle(textColor)
                        .padding(.leading, 16)
                    Slider(value: $fontSize,
                           in: 0...7, step: 1)
                    .tint(textColor)
                    .frame(height: 8)
                    .padding(.horizontal)
                    .onChange(of: fontSize) { newValue in
                        userPreferences.setValue(key: .fontSize, type: newValue)
                        fontSize = newValue
                    }
                    Text("A")
                        .frame(height: 54)
                        .font(.system(size: 32))
                        .foregroundStyle(textColor)
                        .padding(.trailing, 16)
                }
                HStack(spacing: 0) {
                    ForEach(DCFontFamily.allCases, id: \.self) { font in
                        Button {
                            userPreferences.setValue(key: .fontFamily,
                                                     type: font.rawValue)
                            textFont = font.rawValue
                        } label: {
                            Text(font.name)
                                .frame(height: 54)
                                .font(font.font)
                                .foregroundStyle(textColor)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 0) {
                    ForEach(DCDesktopMode.allCase, id: \.self) { desktop in
                        Button {
                            userPreferences.setValue(key: .desktopMode,
                                                     type: desktop.mode)
                            desktopMode = desktop.mode
                        } label: {
                            HStack(spacing: 0) {
                                Text(desktop.name)
                                    .font(.system(size: 13))
                                    .foregroundStyle(textColor)
                                    .padding()
                                Image(systemName: "sun.max.fill")
                                    .foregroundStyle(desktop.iconColor)
                            }
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(DCBookrOrientation.allCases, id: \.self) { orientation in
                        Button {
                            userPreferences.setValue(key: .bookOrientation,
                                                     type: orientation.rawValue)
                            self.orientation = orientation.rawValue
                        } label: {
                            HStack(spacing: 0) {
                                Text(orientation.name)
                                    .font(.system(size: 13))
                                    .foregroundStyle(textColor)
                                    .padding()
                                orientation.icon
                            }
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 16)
    }
}

#if DEBUG

// #Preview {
//    DCReaderSettingsView(userPreferences: DCUserPreferencesMock())
// }

#endif
