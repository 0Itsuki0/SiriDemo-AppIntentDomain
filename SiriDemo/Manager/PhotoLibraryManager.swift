//
//  PhotoLibraryManager.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//


import Photos
import SwiftUI

@Observable
final class PhotoLibraryManager: NSObject, Sendable {
    @MainActor var assets: [Asset] = []
    
    let cacheManager = CachedImageManager.shared
    
    enum PhotoLibraryError: LocalizedError {
        case error(Error)
        case cancelled
        case failed
    }
    
    private(set) var fetchResult: PHFetchResult<PHAsset> = .init()

    override init() {
        super.init()
        Task.detached {
            let isAuthorized = await self.checkAuthorization()
            if (!isAuthorized) {
                return
            }
            PHPhotoLibrary.shared().register(self)
            await self.refreshPhotoAssets()
        }
    }
    
//    func load() {
//        Task.detached {
//            let isAuthorized = await self.checkAuthorization()
//            if (!isAuthorized) {
//                return
//            }
//            PHPhotoLibrary.shared().register(self)
//            await self.refreshPhotoAssets()
//        }
//    }

    private func checkAuthorization() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            print("Photo library access authorized.")
            return true
        case .notDetermined:
            print("Photo library access not determined.")
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        case .denied:
            print("Photo library access denied.")
            return false
        case .limited:
            print("Photo library access limited.")
            return false
        case .restricted:
            print("Photo library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async {
        var newFetchResult = fetchResult
        if newFetchResult == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            newFetchResult = PHAsset.fetchAssets(with: nil)
        }
        
        var assets: [Asset] = []

        if let newFetchResult = newFetchResult {
            self.fetchResult = newFetchResult

            newFetchResult.enumerateObjects { (object, count, stop) in
                assets.append(Asset(phAsset: object))
            }
            
            await MainActor.run { [assets] in
                self.assets = assets
            }
            
//            Task {
//                let entities = assets.map({$0.entity})
//                try await CSSearchableIndex.default().indexAppEntities(entities)
//            }
        }
    }
    
    @MainActor
    func assets(for ids: [Asset.ID]) -> [Asset] {
        var returnAssets: [Asset] = []
        ids.forEach { id in
            returnAssets.append(contentsOf: assets.filter({$0.id == id}))
        }
        return returnAssets
    }
    
}

extension PhotoLibraryManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let changes = changeInstance.changeDetails(for: self.fetchResult) else { return }
            await self.refreshPhotoAssets(changes.fetchResultAfterChanges)
        }
    }
}
