//
//  CustomExtensions.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import Foundation
import RealmSwift
import SwiftUI

// MARK: String

extension String {
    var decodeB64: String {
        guard let base64String = self.data(using: .utf8),
              let decodedData = Data(base64Encoded: base64String),
              let decodedString = String(data: decodedData, encoding: .utf8)else {
            return ""
        }
        return decodedString
    }

    var timeMillis: Double {
        if let time = Double(self) {
            return time * 1000
        }
        return 0
    }

    var capitalizingFirstLetter: String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }

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

    var clearEscaping: String {
        self.replacingOccurrences(of: "[\n\r]", with: "", options: .regularExpression)
    }

    var clearCommas: String {
        self.replacingOccurrences(of: ",", with: ".")
    }

    var fileName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    var fileExtension: String {
        URL(fileURLWithPath: self).pathExtension
    }

    var jpgExtension: String {
        "jpg"
    }

    var normalized: String {
        self.folding(options: .diacriticInsensitive, locale: .current)
    }

    var trim: String {
        self.trimmingCharacters(in: .whitespaces)
    }

    var isIntConvertible: Bool {
        return Int(self) != nil
    }
}

// MARK: Int

extension Int {
    var toString: String {
        "\(self)"
    }

    var toDouble: Double {
        Double(self)
    }

    var toFloat: Float {
        Float(self)
    }

    var toCGFloat: CGFloat {
        CGFloat(self)
    }
}

extension CGFloat {
    var toInt: Int {
        Int(self)
    }
}

extension Float {
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }

    var toInt: Int {
        Int(self)
    }

    var toDouble: Double {
        Double(self)
    }

    var toString: String {
        "\(self)"
    }

    var toStringNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// MARK: Double

extension Double {
    var toString: String {
        "\(self)"
    }

    var toStringNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    var roundWithNoDecimals: Double {
        String(format: "%.0f", self).toDouble
    }

    var toFloat: Float {
        Float(self)
    }

    var toInt: Int {
        Int(self)
    }
}
// MARK: Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(.sRGB,
                  red: Double(red) / 255,
                  green: Double(green) / 255,
                  blue: Double(blue) / 255,
                  opacity: Double(alpha) / 255
        )
    }

    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "000000"
        }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        var alpha = Float(1.0)
        if components.count >= 4 {
            alpha = Float(components[3])
        }
        if alpha != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(red * 255),
                          lroundf(green * 255),
                          lroundf(blue * 255),
                          lroundf(alpha * 255))
        } else {
            return String(format: "%02lX%02lX%02lX",
                          lroundf(red * 255),
                          lroundf(green * 255),
                          lroundf(blue * 255))
        }
    }
}

// MARK: Data -

extension Data {
    var toString: String {
        return String(data: self, encoding: .utf8) ?? ""
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
