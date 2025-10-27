//
//  DCUserPreferencesMock.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 27/10/25.
//

final class DCUserPreferencesMock: DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any) {}

    func getBool(for key: DCUserPreferences.CacheKey) -> Bool {
        false
    }

    func getString(for key: DCUserPreferences.CacheKey) -> String? {
        ""
    }

    func getDouble(for key: DCUserPreferences.CacheKey) -> Double? {
        0
    }

    func getInt(for key: DCUserPreferences.CacheKey) -> Int {
        100
    }

    func getData<T>(for key: DCUserPreferences.CacheKey, of type: T.Type) -> T? where T: Decodable {
        nil
    }
}
