//
//  RBook.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 17/1/26.
//

import Foundation
import RealmSwift

final class RBook: Object {

    private enum Constants {
        static let primaryKey = "uuid"
    }

    @Persisted var uuid: String = ""
    @Persisted var title: String = ""
    @Persisted var author: String = ""
    @Persisted var coverPath: String = ""
    @Persisted var language: String = ""
    @Persisted var publisher: String = ""
    @Persisted var bookVersion: String = ""
    @Persisted var bookDate: String = ""
    @Persisted var descriptionHTML: String = ""
    @Persisted var createdAt: Double = 0
    @Persisted var updatedAt: Double = 0

    public override static func primaryKey() -> String {
        return Constants.primaryKey
    }
}
