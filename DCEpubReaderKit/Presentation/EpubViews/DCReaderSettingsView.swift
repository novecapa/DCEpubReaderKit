//
//  DCReaderSettingsView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import SwiftUI

struct DCReaderSettingsView: View {

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    // TODO: --
                } label: {
                    Text("A")
                        .font(.callout)
                        .foregroundStyle(.black)
                        .padding()
                }
                .padding(.leading, 12)
                Spacer()
                Button {
                    // TODO: --
                } label: {
                    Text("A")
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                        .padding()
                }
                .padding(.trailing, 12)
                Spacer()
            }
            HStack {
                Button {
                    // TODO: --
                } label: {
                    Text("AndadaPro")
                        .font(.fontType(.andadaPro(12)))
                        .foregroundStyle(.black)
                        .padding()
                }
                Button {
                    // TODO: --
                } label: {
                    Text("Lato")
                        .font(.fontType(.lato(12)))
                        .foregroundStyle(.black)
                        .padding()
                }
                Button {
                    // TODO:
                } label: {
                    Text("Lora")
                        .font(.fontType(.lora(12)))
                        .foregroundStyle(.black)
                        .padding()
                }
                Button {
                    // TODO:
                } label: {
                    Text("Raleway")
                        .font(.fontType(.raleway(12)))
                        .foregroundStyle(.black)
                        .padding()
                }
                Button {
                    // TODO:
                } label: {
                    Text("Roboto")
                        .font(.fontType(.roboto(12)))
                        .foregroundStyle(.black)
                        .padding()
                }
            }
            HStack {
                Button {
                    // TODO:
                } label: {
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
                .padding(.horizontal, 12)
                Button {
                    // TODO:
                } label: {
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
                .padding(.horizontal, 12)
            }
            Spacer()
        }
    }
}

#if DEBUG

#Preview {
    DCReaderSettingsView()
}

#endif
