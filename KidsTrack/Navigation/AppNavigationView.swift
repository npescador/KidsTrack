import Observation
import SwiftUI

/// Root view wiring the shared navigation coordinator into a `NavigationStack`.
struct AppNavigationView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var coordinator: AppNavigationCoordinator

    init(
        container: LoginViewModelBuilding & PasswordResetViewModelBuilding &
        CreateFamilyViewModelBuilding & AuthSessionHandling & SessionResetting
    ) {
        _coordinator = State(
            initialValue: AppNavigationCoordinator(
                loginFactory: container,
                passwordResetFactory: container,
                createFamilyFactory: container,
                sessionHandler: container,
                sessionResetter: container
            )
        )
    }

    init(coordinator: AppNavigationCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            coordinator.makeDestination(for: coordinator.root)
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.makeDestination(for: route)
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .inactive else { return }
            coordinator.path = NavigationPath() // reset ephemeral pushes on background
        }
    }
}
