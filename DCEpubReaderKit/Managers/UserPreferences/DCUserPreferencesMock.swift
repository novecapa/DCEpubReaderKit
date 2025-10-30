//
//  DCUserPreferencesMock.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 27/10/25.
//

import Foundation

final class DCUserPreferencesMock: DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any) {}

    func getString(for key: DCUserPreferences.CacheKey) -> String? {
        ""
    }

    func getCGFloat(for key: DCUserPreferences.CacheKey) -> CGFloat? {
        23.0
    }
}
