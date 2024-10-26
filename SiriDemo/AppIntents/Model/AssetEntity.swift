//
//  AssetEntity.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/24.
//


import AppIntents
import CoreLocation
import CoreTransferable
import Photos

@AssistantEnum(schema: .photos.assetType)
enum AssetType: String, AppEnum {
    case photo
    case video

    static let caseDisplayRepresentations: [AssetType: DisplayRepresentation] = [
        .photo: "Photo",
        .video: "Video"
    ]
}

@AssistantEntity(schema: .photos.asset)
struct AssetEntity: IndexedEntity {

    let id: String
    let asset: Asset
        
    var creationDate: Date?
    var location: CLPlacemark?
    var assetType: AssetType?
    var isFavorite: Bool
    var isHidden: Bool
    var hasSuggestedEdits: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "Photo",
            subtitle: "\(asset.creationDate)"
        )
    }
    
    static let defaultQuery = AssetQuery()

    struct AssetQuery: EntityQuery {
        @Dependency
        var library: PhotoLibraryManager

        @MainActor
        func entities(for identifiers: [AssetEntity.ID]) async throws -> [AssetEntity] {
            return library.assets(for: identifiers).map { $0.entity }
        }

        @MainActor
        func suggestedEntities() async throws -> [AssetEntity] {
            return library.assets.prefix(3).map { $0.entity }
        }
        
        @MainActor
        func defaultResult() async -> AssetEntity? {
            library.assets.first?.entity
        }
    }

}

extension AssetEntity: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { entity in
            try await CachedImageManager.shared.requestImageData(for: entity.asset)
        }
    }
}


