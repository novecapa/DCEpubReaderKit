//
//  DCOPFPackage.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

public struct DCOPFPackage {
    public let opfURL: URL
    public var metadata: DCOPFMetadata
    public var manifest: [DCManifestItem]
    public var spine: [DCSpineItem]
    public var guide: [DCGuideRef]
}
