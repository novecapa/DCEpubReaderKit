//
//  DCReaderSettingsView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import SwiftUI

struct DCReaderSettingsView: View {

    @State private var fontSizeBinding: CGFloat = 4

    private var textFont: String = ""
    private var desktopMode: String = ""
    private let userPreferences: DCUserPreferencesProtocol

    init(userPreferences: DCUserPreferencesProtocol = DCUserPreferences(userPreferences: UserDefaults.standard)) {
        self.userPreferences = userPreferences
        let savedFontSize = userPreferences.getCGFloat(for: .fontSize) ?? 4
        _fontSizeBinding = State(initialValue: savedFontSize)
        textFont = userPreferences.getString(for: .fontFamily) ?? "original"
        desktopMode = userPreferences.getString(for: .desktopMode) ?? ""
    }

    private var backgroundColor: Color {
        let desktopMode = userPreferences.getString(for: .desktopMode) ?? ""
        switch desktopMode {
        case "nightMode", "redMode":
            return Color(.backgroundNight)
        default:
            return Color(.backgroundLight)
        }
    }

    private var textColor: Color {
        let desktopMode = userPreferences.getString(for: .desktopMode) ?? ""
        switch desktopMode {
        case "nightMode", "redMode":
            return Color(.backgroundLight)
        default:
            return Color(.backgroundNight)
        }
    }

    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("A")
                        .frame(height: 54)
                        .font(.system(size: 13))
                        .foregroundStyle(textColor)
                        .padding(.leading, 16)
                    Slider(value: $fontSizeBinding,
                           in: 0...7, step: 1)
                    .tint(textColor)
                    .frame(height: 8)
                    .padding(.horizontal)
                    .onChange(of: fontSizeBinding) { newValue in
                        userPreferences.setValue(key: .fontSize, type: newValue)
                    }
                    Text("A")
                        .frame(height: 54)
                        .font(.system(size: 32))
                        .foregroundStyle(textColor)
                        .padding(.trailing, 16)
                }
                HStack(spacing: 0) {
                    Button {
                        userPreferences.setValue(key: .fontFamily, type: "original")
                    } label: {
                        Text("Original")
                            .frame(height: 54)
                            .font(.system(size: 13))
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        userPreferences.setValue(key: .fontFamily, type: "andada")
                    } label: {
                        Text("AndadaPro")
                            .frame(height: 54)
                            .font(.fontType(.andadaPro(13)))
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        userPreferences.setValue(key: .fontFamily, type: "lato")
                    } label: {
                        Text("Lato")
                            .frame(height: 54)
                            .font(.fontType(.lato(13)))
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        userPreferences.setValue(key: .fontFamily, type: "lora")
                    } label: {
                        Text("Lora")
                            .frame(height: 54)
                            .font(.fontType(.lora(13)))
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        userPreferences.setValue(key: .fontFamily, type: "raleway")
                    } label: {
                        Text("Raleway")
                            .frame(height: 54)
                            .font(.fontType(.raleway(13)))
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                HStack(spacing: 0) {
                    Button {
                        userPreferences.setValue(key: .desktopMode, type: "")
                    } label: {
                        HStack(spacing: 0) {
                            Text("Day")
                                .font(.system(size: 13))
                                .foregroundStyle(textColor)
                                .padding()
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(.gray)
                        }
                        .frame(height: 54)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    Button {
                        userPreferences.setValue(key: .desktopMode, type: "nightMode")
                    } label: {
                        HStack(spacing: 0) {
                            Text("Night")
                                .font(.system(size: 13))
                                .foregroundStyle(textColor)
                                .padding()
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.gray)
                        }
                        .frame(height: 54)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    Button {
                        userPreferences.setValue(key: .desktopMode, type: "redMode")
                    } label: {
                        HStack(spacing: 0) {
                            Text("Red")
                                .font(.system(size: 13))
                                .foregroundStyle(.red)
                                .padding()
                            Image(systemName: "rays")
                                .foregroundStyle(.red)
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
                HStack(spacing: 0) {
                    Button {
                        // TODO:
                    } label: {
                        HStack(spacing: 0) {
                            Text("Vertical")
                                .font(.system(size: 13))
                                .foregroundStyle(textColor)
                                .padding()
                            Image(.verticalRead)
                        }
                        .frame(height: 54)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    Button {
                        // TODO:
                    } label: {
                        HStack(spacing: 0) {
                            Text("Horizontal")
                                .font(.system(size: 13))
                                .foregroundStyle(textColor)
                                .padding()
                            Image(.horizontalRead)
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
            .padding(.top, 16)
    }
}

#if DEBUG

#Preview {
    DCReaderSettingsView(userPreferences: DCUserPreferencesMock())
}

#endif
