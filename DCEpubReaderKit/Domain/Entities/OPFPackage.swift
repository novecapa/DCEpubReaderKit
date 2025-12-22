//
//  OPFPackage.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 15/10/25.
//

import Foundation

public struct OPFPackage {
    public let opfURL: URL
    public var metadata: OPFMetadata
    public var manifest: [ManifestItem]
    public var spine: [SpineItem]
    public var guide: [GuideRef]
}
