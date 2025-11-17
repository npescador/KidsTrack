//
//  KidsTrackApp.swift
//  KidsTrack
//
//  Created by Ignacio Pescador Ruiz on 23/10/25.
//

import FirebaseCore
import SwiftUI

@main
struct KidsTrackApp: App {
    private let container: AppContainer

    init() {
        FirebaseApp.configure()
        self.container = AppContainer()
    }

    var body: some Scene {
        WindowGroup {
            AppNavigationView(container: container)
        }
    }
}
