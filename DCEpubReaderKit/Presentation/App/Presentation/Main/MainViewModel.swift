//
//  MainViewModel.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 5/2/26.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    
    @Published var books: [EBookEntity] = []
}

// MARK: - Methods

extension MainViewModel {
    func loadBooks() {
        do {
            
        } catch {
            
        }
    }
}
