import SwiftUI

/// Placeholder for the authenticated area until real family selection is wired.
struct FamilySelectionPlaceholderView: View {
    var isShowingLogoutAlert: Bool = false
    var onConfirmLogout: () -> Void = {}
    var onCancelLogout: () -> Void = {}
    var errorMessage: String?
    var onDismissError: () -> Void = {}
    var onCreateFamily: () -> Void = {}
    var onLogout: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Select a family")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                Text("No families yet.")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("Create a family to start tracking schedules and expenses.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button(action: onCreateFamily) {
                Text("Create family")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .background(Color.accentColor)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(action: onLogout) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
        .navigationTitle("Families")
        .alert(
            "Do you want to sign out?",
            isPresented: .init(
                get: { isShowingLogoutAlert },
                set: { isPresented in
                    if !isPresented {
                        onCancelLogout()
                    }
                }
            ),
            actions: {
                Button("Cancel", role: .cancel, action: onCancelLogout)
                Button("Sign out", role: .destructive, action: onConfirmLogout)
            }
        )
        .alert(
            "Sign out failed",
            isPresented: .init(
                get: { errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        onDismissError()
                    }
                }
            ),
            presenting: errorMessage
        ) { _ in
            Button("OK", role: .cancel, action: onDismissError)
        } message: { message in
            Text(message)
        }
    }
}

#Preview {
    NavigationStack {
        FamilySelectionPlaceholderView(onLogout: {})
    }
}
