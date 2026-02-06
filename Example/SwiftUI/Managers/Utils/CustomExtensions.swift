//
//  CustomExtensions.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import Foundation
import RealmSwift
import SwiftUI
internal import Realm

// MARK: String

extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

    var toDouble: Double {
        guard let value = Double(self) else {
            return 0.0
        }
        return value
    }

    var toFloat: Float {
        Float(self) ?? 0
    }

    var toInt: Int {
        guard let value = Int(self) else {
            return 0
        }
        return value
    }

    var stringDateToMillis: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let realDate = formatter.date(from: self)
        if let millis = realDate?.timeMillis {
            return "\(millis)"
        }
        formatter.dateFormat = "dd-MM-yyyy"
        let realDate2 = formatter.date(from: self)
        if let millis = realDate2?.timeMillis {
            return "\(millis)"
        }
        return self
    }

    var stringDateInddMMyyyy: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date(timeIntervalSince1970: self.toDouble / 1000))
    }
}

// MARK: Realm

extension Results {
    var toArray: [Element] {
        compactMap { $0 }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Object {
    func detached() -> Self {
        let detached = Self()
        for property in objectSchema.properties {
            detached.setValue(self.value(forKey: property.name), forKey: property.name)
        }
        return detached
    }
}

// MARK: Date

extension Date {
    var timeMillis: Double {
        (self.timeIntervalSince1970 * 1000.0).rounded()
    }

    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    var toddMMyyyy: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
}
