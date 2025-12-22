//
//  Utils.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 22/12/25.
//

import Foundation
import SystemConfiguration
import UIKit

protocol UtilsProtocol {
    var currentMillis: Double { get }
    var documentsDirectory: URL { get }
    var fileManager: FileManager { get }
    func createDirectory(directoryName: String)
    func realmFileURL() -> URL
    var hasConnection: Bool { get }
    var bundleId: String { get }
    var appVersion: String { get }
    var osVersion: String { get }
    var deviceModel: String { get }
    var deviceVersion: String { get }
    var buildVersion: String { get }
    var identifierForVendor: String { get }
    func fileExists(_ filePath: URL) -> Bool
    func clearSensitiveData()
}

class Utils: UtilsProtocol {

    enum Directories: String {
        case database
    }

    private enum Constants {
        static let realmFile = "default.realm"
        static let shortVersion = "CFBundleShortVersionString"
        static let bundleVersion = "CFBundleVersion"
        static let nVersion = "0.0.0"
        static let nBundleId = "no.bundle.inde"
    }

    // MARK: - Date
    var currentMillis: Double {
        Date().timeMillis
    }

    // MARK: - Files and folders
    var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    var fileManager: FileManager {
        FileManager.default
    }

    func createDirectory(directoryName: String) {
        let fullPath = documentsDirectory.appendingPathComponent(directoryName)
        if !fileManager.fileExists(atPath: fullPath.path) {
            try? fileManager.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func realmFileURL() -> URL {
        documentsDirectory
            .appendingPathComponent(Constants.realmFile)
    }

    func getDirectory(_ agentUid: String, folder: Directories) -> URL {
        let folder = documentsDirectory
            .appendingPathComponent(agentUid)
            .appendingPathComponent(folder.rawValue)

        guard !fileManager.fileExists(atPath: folder.path) else {
            return folder
        }
        try? fileManager.createDirectory(
            atPath: folder
                .relativePath, withIntermediateDirectories: true, attributes: nil
        )
        return folder
    }

    func fileExists(_ filePath: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return false
        }
        return true
    }

    func clearSensitiveData() {}

    // MARK: - Check Internet connection

    var hasConnection: Bool {
        Reachability.isConnectedToNetwork()
    }

    // MARK: - App

    var bundleId: String {
        if let text = Bundle.main.bundleIdentifier {
            return text
        } else {
            return Constants.nBundleId
        }
    }

    var appVersion: String {
        guard let shortVersion = Bundle.main.infoDictionary?[Constants.shortVersion] as? String,
              let bundleVersion = Bundle.main.infoDictionary?[Constants.bundleVersion] as? String else {
            return Constants.nVersion
        }
        return "V. \(shortVersion) (\(bundleVersion))"
    }

    var osVersion: String {
        UIDevice.current.systemVersion
    }

    var buildVersion: String {
        guard let bundleVersion = Bundle.main.infoDictionary?[Constants.bundleVersion] as? String else {
            return "-1"
        }
        return bundleVersion
    }

    var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #if targetEnvironment(simulator)
        if let simId = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return "Simulator - \(simId)"
        }
        #endif
        return identifier
    }

    var deviceVersion: String {
        UIDevice.current.systemVersion
    }

    var identifierForVendor: String {
        guard let identifier = UIDevice.current.identifierForVendor?.uuidString else {
            // assertionFailure()
            return ""
        }
        return identifier
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0,
                                      sin_family: 0,
                                      sin_port: 0,
                                      sin_addr: in_addr(s_addr: 0),
                                      sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
}
