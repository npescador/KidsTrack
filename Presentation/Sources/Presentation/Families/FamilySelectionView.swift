import Shared
import SwiftUI

public struct FamilySelectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: FamilySelectionViewModel
    private let makeCreateFamilyViewModel: () -> CreateFamilyViewModel
    private let makeInviteAdultViewModel: (String) -> InviteAdultViewModel?
    private let onLogout: () -> Void
    private let onCreateFamily: (Family) -> Void

    @State private var isPresentingCreateFamily = false
    @State private var isPresentingInvite = false

    public init(
        viewModel: FamilySelectionViewModel,
        makeCreateFamilyViewModel: @escaping () -> CreateFamilyViewModel,
        makeInviteAdultViewModel: @escaping (String) -> InviteAdultViewModel?,
        onLogout: @escaping () -> Void,
        onCreateFamily: @escaping (Family) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeCreateFamilyViewModel = makeCreateFamilyViewModel
        self.makeInviteAdultViewModel = makeInviteAdultViewModel
        self.onLogout = onLogout
        self.onCreateFamily = onCreateFamily
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 12) {
                header(viewModel: viewModel)

                if let banner = viewModel.banner {
                    successBanner(banner)
                }

                content(viewModel: viewModel)

                primaryActions(canInvite: canInvite)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationTitle("families.title".localized())
        .animation(.easeInOut(duration: 0.25), value: viewModel.banner)
        .animation(.easeInOut(duration: 0.25), value: viewModel.state)
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.load()
            }
        }
        .sheet(isPresented: $isPresentingCreateFamily) {
            NavigationStack {
                CreateFamilyView(
                    viewModel: makeCreateFamilyViewModel(),
                    onCreated: { family in
                        isPresentingCreateFamily = false
                        viewModel.handleCreated(family)
                        onCreateFamily(family)
                    },
                    onCancel: { isPresentingCreateFamily = false }
                )
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isPresentingInvite) {
            if let familyId = viewModel.activeFamily?.id, let inviteVM = makeInviteAdultViewModel(familyId) {
                NavigationStack {
                    InviteAdultView(
                        viewModel: inviteVM,
                        onSent: {
                            isPresentingInvite = false
                            viewModel.banner = String(localized: "invite.success.banner".localized())
                        },
                        onCancel: { isPresentingInvite = false }
                    )
                }
                .presentationDetents([.medium])
            }
        }
    }
}

private extension FamilySelectionView {
    @ViewBuilder
    func header(viewModel: FamilySelectionViewModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("families.title".localized())
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("families.subtitle.select".localized())
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func content(viewModel: FamilySelectionViewModel) -> some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        case .error(let message):
            VStack(spacing: 12) {
                Text("families.error.title".localized())
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(message)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        case .loaded(let families):
            if families.isEmpty {
                VStack(spacing: 8) {
                    Text("families.empty.title".localized())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text("families.empty.subtitle".localized())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                familyList(families: families, active: viewModel.activeFamily)
            }
        }
    }

    @ViewBuilder
    func familyList(families: [Family], active: Family?) -> some View {
        VStack(spacing: 12) {
            ForEach(families, id: \.id) { family in
                Button {
                    viewModel.select(family)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(family.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Text(String(localized: "families.owner.prefix".localized()) + " \(family.ownerId)")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if family.id == active?.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    var hasFamilies: Bool {
        if case .loaded(let families) = viewModel.state {
            return !families.isEmpty
        }
        return false
    }

    var canInvite: Bool {
        hasFamilies && viewModel.activeFamily != nil
    }

    func primaryActions(canInvite: Bool) -> some View {
        VStack(spacing: 12) {
            Button {
                isPresentingInvite = true
            } label: {
                Text("invite.action.primary".localized())
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .background(canInvite ? Color.kidsTrackSurface(for: colorScheme) : Color.gray.opacity(0.2))
                    .foregroundStyle(canInvite ? Color.kidsTrackTextPrimary(for: colorScheme) : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canInvite)
            .accessibilityLabel("invite.action.primary".localized())
            .accessibilityHint("invite.subtitle".localized())

            Button {
                isPresentingCreateFamily = true
            } label: {
                Text("families.action.create".localized())
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
        }
    }

    @ViewBuilder
    func successBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(message)
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
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
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGreen).opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
