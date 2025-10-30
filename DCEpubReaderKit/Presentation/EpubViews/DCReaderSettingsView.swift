//
//  DCReaderSettingsView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import SwiftUI

struct DCReaderSettingsView: View {

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    // TODO: --
                } label: {
                    Text("A")
                        .frame(height: 44)
                        .font(.callout)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.leading, 0.5)
                }
                Button {
                    // TODO: --
                } label: {
                    Text("A")
                        .frame(height: 44)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.trailing, 0.5)
                }
            }
            HStack(spacing: 0) {
                Button {
                    // TODO: --
                } label: {
                    Text("AndadaPro")
                        .frame(height: 44)
                        .font(.fontType(.andadaPro(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Button {
                    // TODO: --
                } label: {
                    Text("Lato")
                        .frame(height: 44)
                        .font(.fontType(.lato(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Button {
                    // TODO:
                } label: {
                    Text("Lora")
                        .frame(height: 44)
                        .font(.fontType(.lora(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Button {
                    // TODO:
                } label: {
                    Text("Raleway")
                        .frame(height: 44)
                        .font(.fontType(.raleway(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Button {
                    // TODO:
                } label: {
                    Text("Roboto")
                        .frame(height: 44)
                        .font(.fontType(.roboto(12)))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
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
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
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
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
            }
        }
        .padding(.top, 16)
    }
}

#if DEBUG

#Preview {
    DCReaderSettingsView()
}

#endif
