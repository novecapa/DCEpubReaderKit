//
//  DCFonts.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 29/10/25.
//

import CoreText
import SwiftUI

enum DCFonts {

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

    static func registerAllFontsIfNeeded() {
        _ = registrationToken
    }

    private static let registrationToken: Void = {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        let fontURLs = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in fontURLs {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()
}

// MARK: - SwiftUI Font

extension Font {
   static func fontType(_ style: DCFonts) -> Font {
       Font(style.uiFont)
   }
}
