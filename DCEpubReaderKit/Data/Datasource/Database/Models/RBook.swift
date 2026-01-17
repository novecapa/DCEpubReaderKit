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

    public override static func primaryKey() -> String {
        return Constants.primaryKey
    }
}
