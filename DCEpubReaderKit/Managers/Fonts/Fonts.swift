//
//  Fonts.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import SwiftUI

enum Fonts {

    case andadaPro(CGFloat)
    case lato(CGFloat)
    case raleway(CGFloat)
    case roboto(CGFloat)
    case lora(CGFloat)

    var uiFont: UIFont {
        switch self {
        case .andadaPro(let size):
            return UIFont.init(name: "AndadaPro-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .lato(let size):
            return UIFont.init(name: "Lato-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .raleway(let size):
            return UIFont.init(name: "Raleway-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .roboto(let size):
            return UIFont.init(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .lora(let size):
            return UIFont.init(name: "Lora-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
}

// MARK: - SwiftUI Font

extension Font {
   static func fontType(_ style: Fonts) -> Font {
       Font(style.uiFont)
   }
}
