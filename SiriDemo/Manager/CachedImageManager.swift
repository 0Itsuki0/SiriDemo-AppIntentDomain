//
//  CachedImageManager.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//


import UIKit
import Photos
import SwiftUI

actor CachedImageManager {
    static let shared = CachedImageManager()

    private let imageManager = PHCachingImageManager()
    
    private var imageContentMode = PHImageContentMode.aspectFit
    
    enum CachedImageError: LocalizedError {
        case error(Error)
        case cancelled
        case failed
    }
    
    private var cachedAssetIdentifiers = [String : Bool]()
    
    private lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        return options
    }()
    
    var cachedImageCount: Int {
        cachedAssetIdentifiers.keys.count
    }
    
    init() {
        imageManager.allowsCachingHighQualityImages = false
    }
    
    
    func startCaching(for assets: [Asset], targetSize: CGSize) {
        let phAssets = assets.compactMap { $0.phAsset }

        phAssets.forEach {
            cachedAssetIdentifiers[$0.localIdentifier] = true
        }
        imageManager.startCachingImages(for: phAssets, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions)
    }

    func stopCaching(for assets: [Asset], targetSize: CGSize) {
        let phAssets = assets.compactMap { $0.phAsset }

        phAssets.forEach {
            cachedAssetIdentifiers.removeValue(forKey: $0.localIdentifier)
        }
        imageManager.stopCachingImages(for: phAssets, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions)
    }
    
    func stopCaching() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    func requestImage(for asset: Asset, targetSize: CGSize) async throws -> UIImage {
        let phAsset = asset.phAsset
        let (image, info): (UIImage?, [AnyHashable : Any]?) = await withCheckedContinuation { continuation in
            var nillableContinuation: CheckedContinuation<(UIImage?, [AnyHashable : Any]?), Never>? = continuation
            
            let _ = imageManager.requestImage(for: phAsset, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions) { image, info in
                nillableContinuation?.resume(returning: (image, info))
                nillableContinuation = nil

            }
        }
        
        if let error = info?[PHImageErrorKey] as? Error {
            print("CachedImageManager requestImage error: \(error.localizedDescription)")
            throw CachedImageError.error(error)
        } else if let cancelled = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue, cancelled {
            print("CachedImageManager request canceled")
            throw CachedImageError.cancelled
        }
        
        if let image = image {
            return image
        } else {
            throw CachedImageError.failed
        }
    }
    
    func requestImageData(for asset: Asset) async throws -> Data  {
        let phAsset = asset.phAsset
        let (imageData, _, _, info): (Data?, String?, CGImagePropertyOrientation, [AnyHashable : Any]?) = await withCheckedContinuation { continuation in
            var nillableContinuation: CheckedContinuation<(Data?, String?, CGImagePropertyOrientation, [AnyHashable : Any]?), Never>? = continuation
            let _ = imageManager.requestImageDataAndOrientation(for: phAsset, options: nil) { imageData, dataUTI, orientation, info in
                nillableContinuation?.resume(returning: (imageData, dataUTI, orientation, info))
                nillableContinuation = nil
            }
        }
        
        if let error = info?[PHImageErrorKey] as? Error {
            print("CachedImageManager requestImage error: \(error.localizedDescription)")
            throw CachedImageError.error(error)
        } else if let cancelled = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue, cancelled {
            print("CachedImageManager request canceled")
            throw CachedImageError.cancelled
        }
        
        if let data = imageData {
            return data
        } else {
            throw CachedImageError.failed
        }
    }

}
