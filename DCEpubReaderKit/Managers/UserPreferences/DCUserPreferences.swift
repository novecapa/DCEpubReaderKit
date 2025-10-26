//
//  DCUserPreferences.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 26/10/25.
//

import Foundation

protocol DCUserPreferencesProtocol {
    func setValue(key: DCUserPreferences.CacheKey, type: Any)
    func getBool(for key: DCUserPreferences.CacheKey) -> Bool
    func getString(for key: DCUserPreferences.CacheKey) -> String?
    func getDouble(for key: DCUserPreferences.CacheKey) -> Double?
    func getInt(for key: DCUserPreferences.CacheKey) -> Int
    func getData<T>(for key: DCUserPreferences.CacheKey, of type: T.Type) -> T? where T: Decodable
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

    func getDouble(for key: DCUserPreferences.CacheKey) -> Double? {
        double(forKey: key.rawValue)
    }

    func getInt(for key: DCUserPreferences.CacheKey) -> Int {
        integer(forKey: key.rawValue)
    }

    func getData<T>(for key: DCUserPreferences.CacheKey, of type: T.Type) -> T? where T: Decodable {
        guard let data = data(forKey: key.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }
}

final class DCUserPreferences: DCUserPreferencesProtocol {

    enum CacheKey: String {
        case currentChapter
        case currentPage
    }

    private let userPreferences: DCUserPreferencesProtocol

    init(userPreferences: DCUserPreferencesProtocol) {
        self.userPreferences = userPreferences
    }

    func setValue(key: CacheKey, type: Any) {
        userPreferences.setValue(key: key, type: type)
    }

    func getBool(for key: CacheKey) -> Bool {
        userPreferences.getBool(for: key)
    }

    func getString(for key: CacheKey) -> String? {
        userPreferences.getString(for: key)
    }

    func getDouble(for key: CacheKey) -> Double? {
        userPreferences.getDouble(for: key)
    }

    func getInt(for key: CacheKey) -> Int {
        userPreferences.getInt(for: key)
    }

    func getData<T>(for key: CacheKey, of type: T.Type) -> T? where T: Decodable {
        userPreferences.getData(for: key, of: type)
    }
}
