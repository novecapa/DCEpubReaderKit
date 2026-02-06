//
//  DCViewHeightKey.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 30/10/25.
//

import SwiftUI

struct DCViewHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    func onHeightChange(_ perform: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: DCViewHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(DCViewHeightKey.self, perform: perform)
    }
}
