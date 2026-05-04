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

    public init(opfURL: URL,
                metadata: DCOPFMetadata,
                manifest: [DCManifestItem],
                spine: [DCSpineItem],
                guide: [DCGuideRef]) {
        self.opfURL = opfURL
        self.metadata = metadata
        self.manifest = manifest
        self.spine = spine
        self.guide = guide
    }
}
