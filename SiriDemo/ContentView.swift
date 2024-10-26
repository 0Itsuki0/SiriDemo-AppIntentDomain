//
//  ContentView.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//

import SwiftUI
import Photos

struct ContentView: View {
    @Environment(PhotoLibraryManager.self) private var library
    @Environment(NavigationManager.self) private var navigation

    var body: some View {
        @Bindable var navigation = navigation

        NavigationStack(path: $navigation.path) {
            Text("Assets Loaded: \(library.fetchResult.count)")
                .foregroundStyle(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            ThumbnailCollectionView()
        }
//        .navigationDestination(item: $navigation.asset, destination: { asset in
//            AssetView(asset: asset)
//        })
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}

#Preview {
    ContentView()
}
