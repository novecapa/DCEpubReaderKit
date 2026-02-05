//
//  MainView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import SwiftUI

struct MainView: View {

    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MainViewBuilder().build()
}
