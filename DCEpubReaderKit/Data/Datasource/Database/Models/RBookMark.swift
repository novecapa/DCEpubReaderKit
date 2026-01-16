//
//  RBookMark.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 21/12/25.
//

import Foundation
import RealmSwift

final class RBookMark: Object {

    enum MarkType: String {
        case hightLihgt
        case note
        case bookMark
        case lastPosition
    }

    private enum Constants {
        static let primaryKey = "compoundKey"
    }

    @Persisted var compoundKey: String = ""
    @Persisted var uuid: String = ""
    @Persisted var bookTitle: String = ""
    @Persisted var text: String = ""
    @Persisted var coords: String = ""
    @Persisted var chapterId: String = ""
    @Persisted var chapterTitle: String = ""
    @Persisted var pageNumber: Int = 0
    @Persisted var textNote: String = ""
    @Persisted var type: String = ""
    @Persisted var lastcoords: String = ""
    @Persisted var lastchapterid: String = ""
    @Persisted var dateCreated: Double = 0
    @Persisted var dateUpdated: Double = 0
    @Persisted var state: Bool = true

    var compound: String {
        "\(uuid)-\(type)"
    }

    public override static func primaryKey() -> String {
        return Constants.primaryKey
    }
}
