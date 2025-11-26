import Presentation
import Shared
import SwiftUI

/// Placeholder for the authenticated area until real family selection is wired.
struct FamilySelectionPlaceholderView: View {
    var isShowingLogoutAlert: Bool = false
    var onConfirmLogout: () -> Void = {}
    var onCancelLogout: () -> Void = {}
    var errorMessage: String?
    var onDismissError: () -> Void = {}
    var createFamilyViewModelBuilder: () -> CreateFamilyViewModel = { .preview() }
    var onFamilyCreated: (Family) -> Void = { _ in }
    var activeFamily: Family?
    var onLogout: () -> Void
    @State private var isPresentingCreateFamily = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Select a family")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            if let activeFamily {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active family")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(activeFamily.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Owner: \(activeFamily.ownerId)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
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
            }

            Button {
                isPresentingCreateFamily = true
            } label: {
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
        .sheet(isPresented: $isPresentingCreateFamily) {
            NavigationStack {
                CreateFamilyView(
                    viewModel: createFamilyViewModelBuilder(),
                    onCreated: { family in
                        isPresentingCreateFamily = false
                        onFamilyCreated(family)
                    },
                    onCancel: {
                        isPresentingCreateFamily = false
                    }
                )
            }
            .presentationDetents([.medium, .large])
        }
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
