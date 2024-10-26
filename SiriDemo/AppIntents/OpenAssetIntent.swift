//
//  OpenAssetIntent.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//


import SwiftUI
import AppIntents


@AssistantIntent(schema: .photos.openAsset)
struct OpenAssetIntent: OpenIntent {
    var target: AssetEntity
    
    @Dependency
    var libraryManager: PhotoLibraryManager

    @Dependency
    var navigationManager: NavigationManager

    @MainActor
    func perform() async throws -> some IntentResult {
        let assets = libraryManager.assets(for: [target.id])
        if let asset = assets.first {
            navigationManager.openAsset(asset)
        }
        return .result()
    }
}
