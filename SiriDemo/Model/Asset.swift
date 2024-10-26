//
//  Asset.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/24.
//

import SwiftUI
import Photos

@Observable
final class Asset: Identifiable {

    let phAsset: PHAsset
    
    var id: String {
        phAsset.localIdentifier
    }
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var creationDate: String {
        Self.dateFormatter.string(from: phAsset.creationDate ?? .now)
    }

    init(phAsset: PHAsset) {
        self.phAsset = phAsset
    }

}

extension Asset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id
    }
}

extension Asset: Transferable, Sendable {

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { asset in
            try await CachedImageManager.shared.requestImageData(for: asset)
        }
    }
}

extension Asset {
    var entity: AssetEntity {
        let entity = AssetEntity(id: id, asset: self)
        
        entity.assetType = .photo
        entity.creationDate = phAsset.creationDate
        entity.location = nil
        entity.isFavorite = phAsset.isFavorite
        entity.isHidden = phAsset.isHidden
        entity.hasSuggestedEdits = false

        return entity
    }
}
