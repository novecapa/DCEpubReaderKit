//
//  RealmError.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

enum RealmError: Error {
    case canNotSaveData(error: String)
    case canNotLoadData(error: String)
    case realmNotAvailable
}
