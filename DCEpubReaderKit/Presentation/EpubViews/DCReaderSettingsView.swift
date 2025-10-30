//
//  DCReaderSettingsView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import SwiftUI

struct DCReaderSettingsView: View {

    @Binding var textSize: CGFloat
    @Binding var textFont: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("A")
                    .frame(height: 54)
                    .font(.callout)
                    .foregroundStyle(.black)
                    .padding(.leading, 12)
                Slider(value: $textSize, in: 0...8, step: 1)
                    .tint(.gray)
                    .frame(height: 8)
                    .padding(.horizontal)
                Text("A")
                    .frame(height: 54)
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                    .padding(.trailing, 12)
            }
            HStack(spacing: 0) {
                Button {
                    textFont = "andada"
                } label: {
                    Text("AndadaPro")
                        .frame(height: 54)
                        .font(.fontType(.andadaPro(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                Button {
                    textFont = "lato"
                } label: {
                    Text("Lato")
                        .frame(height: 54)
                        .font(.fontType(.lato(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                Button {
                    textFont = "lora"
                } label: {
                    Text("Lora")
                        .frame(height: 54)
                        .font(.fontType(.lora(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                Button {
                    textFont = "raleway"
                } label: {
                    Text("Raleway")
                        .frame(height: 54)
                        .font(.fontType(.raleway(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                Button {
                    textFont = "roboto"
                } label: {
                    Text("Roboto")
                        .frame(height: 54)
                        .font(.fontType(.roboto(12)))
                        .foregroundStyle(.black)
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
                            .font(.fontType(.raleway(12)))
                            .foregroundStyle(.black)
                            .padding()
                        Image(.verticalRead)
                            .resizable()
                            .scaledToFit()
                            .tint(.gray)
                            .frame(width: 24,
                                   height: 24)
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
                            .font(.fontType(.roboto(12)))
                            .foregroundStyle(.black)
                            .padding()
                        Image(.horizontalRead)
                            .resizable()
                            .scaledToFit()
                            .tint(.gray)
                            .frame(width: 24,
                                   height: 24)
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
    DCReaderSettingsView(textSize: .constant(4),
                         textFont: .constant("original"))
}

#endif
