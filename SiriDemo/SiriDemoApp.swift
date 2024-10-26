//
//  SiriDemoApp.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/22.
//

import SwiftUI
import AppIntents

@main
struct SiriDemoApp: App {
    let libraryManager: PhotoLibraryManager
    let navigationManager: NavigationManager

    init() {
        let navigationManager = NavigationManager()
        let libraryManager = PhotoLibraryManager()
        AppDependencyManager.shared.add(dependency: libraryManager)
        AppDependencyManager.shared.add(dependency: navigationManager)
        self.libraryManager = libraryManager
        self.navigationManager = navigationManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(libraryManager)
        .environment(navigationManager)
    }
}
