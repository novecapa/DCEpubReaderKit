//
//  DCEpubReaderKitApp.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import SwiftUI

@main
struct DCEpubReaderKitApp: App {

    init () {
        RealmHelper().applyMigrations()
        print("----------------------------------------------------------------")
        print("Documents path: \(FileHelper.shared.getDocumentsDirectory().path)")
        print("----------------------------------------------------------------")
        print("Temp. path: \(FileHelper.shared.getTempFolder().path)")
        print("----------------------------------------------------------------")
        try? FileHelper.shared.clearTempFolder()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
