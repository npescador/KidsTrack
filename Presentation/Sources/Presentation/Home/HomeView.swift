import Domain
import Shared
import SwiftUI

public struct HomeView: View {
    @Environment(\.familyRealtimeSyncer) private var realtimeSyncer
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: HomeViewModel

    private let onManageFamilies: () -> Void
    private let onOpenSchedule: (() -> Void)?
    private let onOpenActivities: (() -> Void)?
    private let onOpenExpenses: (() -> Void)?
    private let onLogout: () -> Void
    private let makeCreateChildViewModel: (Family) -> CreateChildViewModel?
    private let makeEditChildViewModel: (Family, Child) -> CreateChildViewModel?
    private let makeDeleteChildViewModel: (Family, Child) -> DeleteChildViewModel?

    @State private var createChildViewModel: CreateChildViewModel?
    @State private var deleteChildViewModel: DeleteChildViewModel?

    public init(
        viewModel: HomeViewModel,
        onManageFamilies: @escaping () -> Void,
        onOpenSchedule: (() -> Void)? = nil,
        onOpenActivities: (() -> Void)? = nil,
        onOpenExpenses: (() -> Void)? = nil,
        onLogout: @escaping () -> Void,
        makeCreateChildViewModel: @escaping (Family) -> CreateChildViewModel?,
        makeEditChildViewModel: @escaping (Family, Child) -> CreateChildViewModel?,
        makeDeleteChildViewModel: @escaping (Family, Child) -> DeleteChildViewModel?
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onManageFamilies = onManageFamilies
        self.onOpenSchedule = onOpenSchedule
        self.onOpenActivities = onOpenActivities
        self.onOpenExpenses = onOpenExpenses
        self.onLogout = onLogout
        self.makeCreateChildViewModel = makeCreateChildViewModel
        self.makeEditChildViewModel = makeEditChildViewModel
        self.makeDeleteChildViewModel = makeDeleteChildViewModel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header(familyName: viewModel.activeFamilyName)

                quickActions

                switch viewModel.state {
                case .loading, .idle:
                    loadingCard
                case .error(let message):
                    errorCard(message: message)
                case .ready:
                    content(viewModel: viewModel)
                }

                footerActions
            }
            .padding()
        }
        .navigationTitle(Text("home.title".localizedText()))
        .onAppear {
            viewModel.start(using: realtimeSyncer)
        }
        .sheet(item: $createChildViewModel, onDismiss: { createChildViewModel = nil }, content: { vm in
            NavigationStack {
                CreateChildView(
                    viewModel: vm,
                    onSaved: { _ in createChildViewModel = nil },
                    onCancel: { createChildViewModel = nil }
                )
            }
            .presentationDetents([.medium, .large])
        })
        .sheet(item: $deleteChildViewModel, onDismiss: { deleteChildViewModel = nil }, content: { vm in
            DeleteChildConfirmationView(
                viewModel: vm,
                onDeleted: { deleteChildViewModel = nil },
                onCancel: { deleteChildViewModel = nil }
            )
        })
    }
}

private extension HomeView {
    @ViewBuilder
    func header(familyName: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let familyName {
                Text("home.subtitle.family.prefix".localizedText() + " \(familyName)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            } else {
                Text("home.subtitle.nofamily".localizedText())
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("home.quickactions.title".localizedText())
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "home.quick.family".localizedText(),
                    systemImage: "person.2.fill",
                    action: onManageFamilies,
                    color: .kidsTrackPrimaryBlue
                )
                QuickActionButton(
                    title: "home.quick.schedule".localizedText(),
                    systemImage: "calendar",
                    action: onOpenSchedule,
                    color: .kidsTrackPrimaryPurple
                )
                QuickActionButton(
                    title: "home.quick.activities".localizedText(),
                    systemImage: "figure.run.circle",
                    action: onOpenActivities,
                    color: .kidsTrackPrimaryGreen
                )
                QuickActionButton(
                    title: "home.quick.expenses".localizedText(),
                    systemImage: "creditcard",
                    action: onOpenExpenses,
                    color: .kidsTrackPrimaryOrange
                )
            }
        }
    }

    @ViewBuilder
    func content(viewModel: HomeViewModel) -> some View {
        if !viewModel.hasFamily {
            emptyFamilyCard
        } else {
            todaySection(items: viewModel.todayItems, hasChildren: viewModel.hasChildren)
            childrenSection(family: viewModel.activeFamily)
        }
    }

    var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("home.loading.title".localizedText())
                .font(.system(size: 15, weight: .medium, design: .rounded))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    func errorCard(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("home.error.title".localizedText())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text(message)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Button {
                viewModel.loadFamiliesIfNeeded()
            } label: {
                Text("home.error.retry".localizedText())
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.kidsTrackPrimaryBlue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    var emptyFamilyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("home.empty.family.title".localizedText())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text("home.empty.family.subtitle".localizedText())
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Button {
                onManageFamilies()
            } label: {
                Text("home.action.manageFamilies".localizedText())
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .background(Color.kidsTrackPrimaryBlue)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
        )
    }

    @ViewBuilder
    func todaySection(items: [HomeViewModel.TodayItem], hasChildren: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("home.today.title".localizedText())
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
                if let primaryCTA = primaryCTA(hasChildren: hasChildren) {
                    Button {
                        primaryCTA.action()
                    } label: {
                        Text(primaryCTA.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.kidsTrackPrimaryBlue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if items.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("home.today.empty.title".localizedText())
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Text(
                        hasChildren
                            ? "home.today.empty.subtitle.children".localizedText()
                            : "home.today.empty.subtitle.nochildren".localizedText()
                    )
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(items.prefix(6), id: \.id) { item in
                        todayRow(item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func todayRow(_ item: HomeViewModel.TodayItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            let accent: Color = item.kind == .schoolSlot ? .kidsTrackPrimaryPurple : .kidsTrackPrimaryGreen
            VStack {
                Circle()
                    .fill(accent.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: item.kind == .schoolSlot ? "book.fill" : "sportscourt.fill")
                            .foregroundStyle(accent)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(item.childName)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Label {
                        Text(item.timeRange)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    } icon: {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .labelStyle(.titleAndIcon)

                    if let location = item.location, !location.isEmpty {
                        Label {
                            Text(location)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                        } icon: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    func childrenSection(family: Family?) -> some View {
        ChildrenListView(
            activeFamily: family,
            onSelectChild: { child in
                guard let family else { return }
                createChildViewModel = makeEditChildViewModel(family, child)
            },
            onAddChild: {
                guard let family else { return }
                createChildViewModel = makeCreateChildViewModel(family)
            },
            onDeleteChild: { child in
                guard let family else { return }
                deleteChildViewModel = makeDeleteChildViewModel(family, child)
            }
        )
    }

    var footerActions: some View {
        HStack {
            Spacer()
            Button(role: .destructive, action: onLogout) {
                Text("home.action.logout".localizedText())
            }
            .accessibilityLabel(Text("home.action.logout".localizedText()))
        }
        .padding(.top, 8)
    }

    func primaryCTA(hasChildren: Bool) -> (title: String, action: () -> Void)? {
        guard let family = viewModel.activeFamily else {
            return (title: "home.action.manageFamilies".localizedText(), action: onManageFamilies)
        }

        guard !hasChildren else {
            return nil
        }

        return (
            title: "children.action.add".localizedText(),
            action: {
                createChildViewModel = makeCreateChildViewModel(family)
            }
        )
    }
}
