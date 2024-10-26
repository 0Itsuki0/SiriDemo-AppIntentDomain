//
//  AssetView.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//


import SwiftUI
import Photos

struct AssetView: View {
    
    @Environment(PhotoLibraryManager.self) private var photoLibraryManager
    @Environment(\.dismiss) var dismiss

    var asset: Asset
    @State private var image: Image?

    var body: some View {
        
        VStack(spacing: 0) {
            if asset.phAsset.playbackStyle == .image {
                image?
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Oops, Currently only supporting Images.")
            }

        }
                       
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .statusBar(hidden: true)
        .onAppear {
            print("asset view appear")
            Task.detached {
                let uiImage = try await photoLibraryManager.cacheManager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000))
                await MainActor.run {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }

    }
}
