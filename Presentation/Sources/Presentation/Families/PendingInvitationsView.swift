import Shared
import SwiftUI

public struct PendingInvitationsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: PendingInvitationsViewModel
    private let onAccepted: (Family) -> Void
    private let onClose: () -> Void

    public init(
        viewModel: PendingInvitationsViewModel,
        onAccepted: @escaping (Family) -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onAccepted = onAccepted
        self.onClose = onClose
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 16) {
                if let banner = viewModel.banner {
                    bannerView(banner)
                }

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                case .error(let message):
                    errorView(message)
                case .loaded(let invitations):
                    if invitations.isEmpty {
                        emptyState
                    } else {
                        invitationsList(invitations)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(Text("invitations.title".localizedText()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("invite.action.cancel".localizedText(), action: onClose)
                }
            }
        }
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.load()
            }
        }
    }
}

private extension PendingInvitationsView {
    @ViewBuilder
    var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "envelope.open")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text("invitations.empty.title".localizedText())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text("invitations.empty.subtitle".localizedText())
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    func invitationsList(_ invitations: [FamilyInvitation]) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(invitations) { invitation in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(invitation.familyName)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text(invitation.email)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            Button {
                                viewModel.accept(invitation) { family in
                                    onAccepted(family)
                                }
                            } label: {
                                Text("invitations.action.accept".localizedText())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)

                            Button(role: .destructive) {
                                viewModel.reject(invitation)
                            } label: {
                                Text("invitations.action.reject".localizedText())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.kidsTrackSurface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Text("invitations.error.title".localizedText())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text(message)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func bannerView(_ banner: PendingInvitationsViewModel.Banner) -> some View {
        HStack(spacing: 10) {
            Image(systemName: banner.isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundStyle(banner.isError ? Color.red : Color.green)
            Text(banner.message)
                .foregroundStyle(banner.isError ? Color.red : Color.primary)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            Spacer()
            Button {
                viewModel.banner = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.kidsTrackSurface(for: colorScheme))
        .cornerRadius(12)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
