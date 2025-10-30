//
//  DCUserPreferences.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/10/25.
//

import Foundation
import CoreGraphics

protocol DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any)
    func getString(for key: DCUserPreferences.CacheKey) -> String?
    func getCGFloat(for key: DCUserPreferences.CacheKey) -> CGFloat?
}

extension UserDefaults: DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any) {
        setValue(type, forKey: key.rawValue)
        synchronize()
    }

    func getBool(for key: DCUserPreferences.CacheKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func getString(for key: DCUserPreferences.CacheKey) -> String? {
        string(forKey: key.rawValue)
    }

    func getCGFloat(for key: DCUserPreferences.CacheKey) -> CGFloat? {
        if let number = object(forKey: key.rawValue) as? NSNumber {
            return CGFloat(truncating: number)
        }
        return nil
    }
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

    func getString(for key: CacheKey) -> String? {
        switch key {
        case .fontSize:
            let index = Int(getCGFloat(for: key) ?? 4)
            let tokens = [
                "textSizeOne",
                "textSizeTwo",
                "textSizeThree",
                "textSizeFour",
                "textSizeFive",
                "textSizeSix",
                "textSizeSeven",
                "textSizeEight"
            ]
            if (0..<tokens.count).contains(index) {
                return tokens[index]
            }
            return "textSizeFive"
        default:
            return userPreferences.getString(for: key)
        }
    }

    func getCGFloat(for key: CacheKey) -> CGFloat? {
        userPreferences.getCGFloat(for: key)
    }
}
