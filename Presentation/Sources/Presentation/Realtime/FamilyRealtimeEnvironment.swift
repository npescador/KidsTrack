import SwiftUI

/// Box to hold the syncer without actor/isolation warnings inside Environment.
final class FamilyRealtimeSyncerBox: @unchecked Sendable {
    weak var value: FamilyRealtimeSyncCoordinating?

    init(_ value: FamilyRealtimeSyncCoordinating? = nil) {
        self.value = value
    }
}

private struct FamilyRealtimeSyncerKey: EnvironmentKey {
    static let defaultValue = FamilyRealtimeSyncerBox()
}

public extension EnvironmentValues {
    var familyRealtimeSyncer: FamilyRealtimeSyncCoordinating? {
        get { self[FamilyRealtimeSyncerKey.self].value }
        set { self[FamilyRealtimeSyncerKey.self].value = newValue }
    }
}

public extension View {
    func familyRealtimeSyncer(_ syncer: FamilyRealtimeSyncCoordinating?) -> some View {
        environment(\.familyRealtimeSyncer, syncer)
    }
}
