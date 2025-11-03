//
//  DCUserPreferences.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/10/25.
//

import Foundation
import CoreGraphics
import SwiftUICore

protocol DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any)
    func getFontSize() -> DCFontSize
    func getFontFamily() -> DCFontFamily
    func getDesktopMode() -> DCDesktopMode
    func getBookOrientation() -> DCBookrOrientation
}

extension UserDefaults: DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any) {
        setValue(type, forKey: key.rawValue)
        synchronize()
    }

    func getFontSize() -> DCFontSize {
        guard let number = object(forKey: DCUserPreferences.CacheKey.fontSize.rawValue) as? NSNumber else {
            return .textSizeFour
        }
        switch number {
        case 0:
            return .textSizeOne
        case 1:
            return .textSizeTwo
        case 2:
            return .textSizeThree
        case 3:
            return .textSizeFour
        case 4:
            return .textSizeFive
        case 5:
            return .textSizeSix
        case 6:
            return .textSizeSeven
        case 7:
            return .textSizeEight
        default:
            return .textSizeFour
        }
    }

    func getFontFamily() -> DCFontFamily {
        guard let fontFamily = string(forKey: DCUserPreferences.CacheKey.fontFamily.rawValue) else {
            return .original
        }
        switch fontFamily {
        case "original":
            return .original
        case "andada":
            return .andada
        case "lato":
            return .lato
        case "lora":
            return .lora
        case "raleway":
            return .raleway
        default:
            return .original
        }
    }

    func getDesktopMode() -> DCDesktopMode {
        guard let desktopMode = string(forKey: DCUserPreferences.CacheKey.desktopMode.rawValue) else {
            return .lihgt
        }
        switch desktopMode {
        case "":
            return .lihgt
        case "nightMode":
            return .dark
        case "redMode":
            return .red
        default:
            return .lihgt
        }
    }

    func getBookOrientation() -> DCBookrOrientation {
        guard let orientation = string(forKey: DCUserPreferences.CacheKey.bookOrientation.rawValue) else {
            return .horizontal
        }
        switch orientation {
        case "horizontal":
            return .horizontal
        case "vertical":
            return .vertical
        default:
            return .horizontal
        }
    }
}

enum DCFontSize: String {
    case textSizeOne
    case textSizeTwo
    case textSizeThree
    case textSizeFour
    case textSizeFive
    case textSizeSix
    case textSizeSeven
    case textSizeEight

    var size: CGFloat {
        switch self {
        case .textSizeOne:
            return 0
        case .textSizeTwo:
            return 1
        case .textSizeThree:
            return 2
        case .textSizeFour:
            return 3
        case .textSizeFive:
            return 4
        case .textSizeSix:
            return 5
        case .textSizeSeven:
            return 6
        case .textSizeEight:
            return 7
        }
    }
}

enum DCFontFamily: String {
    case original
    case andada
    case lato
    case lora
    case raleway

    var name: String {
        switch self {
        case .original:
            "Original"
        case .andada:
            "AndadaPro"
        case .lato:
            "Lato"
        case .lora:
            "Lora"
        case .raleway:
            "Raleway"
        }
    }

    var font: Font {
        switch self {
        case .original:
            Font.system(size: 12)
        case .andada:
            Font.fontType(.andadaPro(12))
        case .lato:
            Font.fontType(.lato(12))
        case .lora:
            Font.fontType(.lora(12))
        case .raleway:
            Font.fontType(.raleway(12))
        }
    }

    static let allCases: [DCFontFamily] = [
        .original,
        .andada,
        .lato,
        .lora,
        .raleway
    ]
}

enum DCDesktopMode: String {
    case lihgt
    case dark
    case red

    var mode: String {
        switch self {
        case .lihgt:
            ""
        case .dark:
            "nightMode"
        case .red:
            "redMode"
        }
    }

    var name: String {
        switch self {
        case .lihgt:
            "Day"
        case .dark:
            "Dark"
        case .red:
            "rays"
        }
    }

    var icon: String {
        switch self {
        case .lihgt:
            "sun.max.fill"
        case .dark:
            "moon.fill"
        case .red:
            "Red"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .lihgt:
            Color(.backgroundLight)
        case .dark, .red:
            Color(.backgroundNight)
        }
    }

    var textColor: Color {
        switch self {
        case .lihgt:
            Color(.backgroundNight)
        case .dark, .red:
            Color(.backgroundLight)
        }
    }

    var iconColor: Color {
        switch self {
        case .lihgt, .dark:
                .gray
        case .red:
                .red
        }
    }

    static let allCase: [DCDesktopMode] = [
        .lihgt,
        .dark,
        .red
    ]
}

enum DCBookrOrientation: String {
    case vertical
    case horizontal

    var name: String {
        switch self {
        case .vertical:
            "Vertical"
        case .horizontal:
            "Horizontal"
        }
    }

    var icon: Image {
        switch self {
        case .vertical:
            Image(.verticalRead)
        case .horizontal:
            Image(.horizontalRead)
        }
    }

    static let allCases: [DCBookrOrientation] = [
        .vertical,
        .horizontal
    ]
}

final class DCUserPreferences: DCUserPreferencesProtocol {

    enum CacheKey: String {
        case bookOrientation
        case fontSize
        case fontFamily
        case desktopMode
    }

    private let userPreferences: DCUserPreferencesProtocol

    init(userPreferences: DCUserPreferencesProtocol) {
        self.userPreferences = userPreferences
    }

    func setValue(key: CacheKey, type: Any) {
        userPreferences.setValue(key: key, type: type)
    }

    func getFontSize() -> DCFontSize {
        userPreferences.getFontSize()
    }

    func getFontFamily() -> DCFontFamily {
        userPreferences.getFontFamily()
    }

    func getDesktopMode() -> DCDesktopMode {
        userPreferences.getDesktopMode()
    }

    func getBookOrientation() -> DCBookrOrientation {
        userPreferences.getBookOrientation()
    }
}
