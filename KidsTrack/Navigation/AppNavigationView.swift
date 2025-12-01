import Observation
import Presentation
import SwiftUI

/// Root view wiring the shared navigation coordinator into a `NavigationStack`.
struct AppNavigationView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var coordinator: AppNavigationCoordinator
    private let realtimeSyncer: FamilyRealtimeSyncCoordinating?

    init(
        container: LoginViewModelBuilding & PasswordResetViewModelBuilding &
        CreateFamilyViewModelBuilding & InviteAdultViewModelBuilding & PendingInvitationsViewModelBuilding &
        FamilySelectionViewModelBuilding & AuthSessionHandling & SessionResetting & FamilyRealtimeSyncProviding
    ) {
        self.realtimeSyncer = container.familyRealtimeSyncer
        _coordinator = State(
            initialValue: AppNavigationCoordinator(
                loginFactory: container,
                passwordResetFactory: container,
                familySelectionFactory: container,
                createFamilyFactory: container,
                inviteAdultFactory: container,
                pendingInvitesFactory: container,
                sessionHandler: container,
                sessionResetter: container
            )
        )
    }

    init(coordinator: AppNavigationCoordinator, realtimeSyncer: FamilyRealtimeSyncCoordinating? = nil) {
        _coordinator = State(initialValue: coordinator)
        self.realtimeSyncer = realtimeSyncer
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
            switch phase {
            case .inactive:
                coordinator.path = NavigationPath() // reset ephemeral pushes on background
            case .active:
                realtimeSyncer?.restart() // reattach listeners after background/network drops
            default:
                break
            }
        }
        .environment(\.familyRealtimeSyncer, realtimeSyncer)
    }
}
