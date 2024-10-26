//
//  ThumbnailCollectionView.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//

import SwiftUI
import Photos

struct ThumbnailCollectionView: View {
    @Environment(PhotoLibraryManager.self) private var photoLibraryManager
    @Environment(NavigationManager.self) private var navigation

    private static let itemSpacing = 2.0
    private var thumbnailSize: CGSize = CGSize(width: UIScreen.main.bounds.size.width/3 - Self.itemSpacing, height: UIScreen.main.bounds.size.width/3 - Self.itemSpacing)

    var body: some View {
        @Bindable var navigation = navigation

        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: thumbnailSize.width, maximum: thumbnailSize.width), spacing: Self.itemSpacing)
            ], spacing: Self.itemSpacing) {
                ForEach(photoLibraryManager.assets) { asset in
                    NavigationLink(value: asset) {
                        ThumbnailItemView(asset: asset, thumbnailSize: thumbnailSize)
                    }
                }
            }
            .padding(.vertical, Self.itemSpacing)
        }
        .onAppear {
            Task.detached {
                await photoLibraryManager.cacheManager.startCaching(for: photoLibraryManager.assets, targetSize: thumbnailSize)
            }
        }
        .onDisappear {
            Task.detached {
                await photoLibraryManager.cacheManager.stopCaching(for: photoLibraryManager.assets, targetSize: thumbnailSize)
            }
        }
        .navigationDestination(for: Asset.self) { asset in
            AssetView(asset: asset)
        }
    }
}


fileprivate struct ThumbnailItemView: View {
    @Environment(PhotoLibraryManager.self) private var photoLibraryManager

    var asset: Asset
    var thumbnailSize: CGSize
    
    @State private var image: Image?

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height, alignment: .center)
                    .clipped()

            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .task {
            guard image == nil else { return }
            do {
                let uIImage = try await photoLibraryManager.cacheManager.requestImage(for: asset, targetSize: thumbnailSize)
                image = Image(uiImage: uIImage)
            } catch(let error) {
                print(error)
            }
        }
    }
}
