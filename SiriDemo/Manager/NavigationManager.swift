//
//  NavigationManager.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/23.
//

import SwiftUI
import Photos

@MainActor @Observable
class NavigationManager {
    var path = NavigationPath()
    
    func openAsset(_ asset: Asset) {
        self.path = NavigationPath()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.path = NavigationPath([asset])
        }
    }
}
