//
//  KidsTrackApp.swift
//  KidsTrack
//
//  Created by Ignacio Pescador Ruiz on 23/10/25.
//

import Presentation
import SwiftUI

@main
struct KidsTrackApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: container.makeLoginViewModel())
        }
    }
}
