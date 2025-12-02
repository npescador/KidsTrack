import Shared
import SwiftUI

public struct ChildrenListView: View {
    @Environment(\.familyRealtimeSyncer) private var realtimeSyncer
    @Environment(\.colorScheme) private var colorScheme

    private let activeFamily: Family?
    private let onSelectChild: ((Child) -> Void)?
    private let onAddChild: (() -> Void)?

    @State private var viewModel: ChildrenListViewModel

    public init(
        activeFamily: Family?,
        viewModel: ChildrenListViewModel? = nil,
        onSelectChild: ((Child) -> Void)? = nil,
        onAddChild: (() -> Void)? = nil
    ) {
        self.activeFamily = activeFamily
        self.onSelectChild = onSelectChild
        self.onAddChild = onAddChild
        _viewModel = State(
            initialValue: viewModel ?? ChildrenListViewModel(
                activeFamily: activeFamily
            )
        )
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        VStack(alignment: .leading, spacing: 12) {
            header(familyName: viewModel.familyName ?? activeFamily?.name)
            content(for: viewModel.state)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kidsTrackSurface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
        )
        .onAppear {
            viewModel.updateActiveFamily(activeFamily)
            viewModel.start(using: realtimeSyncer)
        }
        .onChange(of: activeFamily) { _, newFamily in
            viewModel.updateActiveFamily(newFamily)
        }
    }
}

private extension ChildrenListView {
    @ViewBuilder
    func header(familyName: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("children.section.title".localized())
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            if let familyName {
                HStack(spacing: 6) {
                    Text("children.section.family.prefix".localized())
                    Text(familyName)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
            } else {
                Text("children.section.subtitle".localized())
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func content(for state: ChildrenListViewModel.State) -> some View {
        switch state {
        case .noFamily:
            stateCard(
                title: "children.family.missing.title".localized(),
                subtitle: "children.family.missing.subtitle".localized()
            )
        case .idle, .loading:
            loadingView
        case .loaded(let children):
            if children.isEmpty {
                emptyState
            } else {
                childrenList(children)
            }
        }
    }

    func stateCard(title: LocalizedStringResource, subtitle: LocalizedStringResource) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text(subtitle)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    var loadingView: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("children.loading.title".localized())
                .font(.system(size: 14, weight: .regular, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("children.empty.title".localized())
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text("children.empty.subtitle".localized())
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Button {
                onAddChild?()
            } label: {
                Text("children.action.add".localized())
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .background(Color.kidsTrackPrimaryBlue.opacity(onAddChild == nil ? 0.35 : 1))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(onAddChild == nil)
            .accessibilityHint(Text("children.action.add.hint".localized()))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    func childrenList(_ children: [Child]) -> some View {
        VStack(spacing: 10) {
            ForEach(children, id: \.id) { child in
                childRow(child)
            }
        }
    }

    @ViewBuilder
    func childRow(_ child: Child) -> some View {
        let avatarColor = child.colorHex.flatMap(Color.init(hex:)) ?? .accentColor
        let initials = String(child.name.prefix(1)).uppercased()

        let row = HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.18))
                    .frame(width: 46, height: 46)
                Text(initials)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(avatarColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
                if let grade = child.grade, !grade.isEmpty {
                    Label {
                        Text(grade)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                    } icon: {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color.kidsTrackIconMuted(for: colorScheme))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.kidsTrackIconMuted(for: colorScheme))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kidsTrackSurface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
        )

        if let onSelectChild {
            Button {
                onSelectChild(child)
            } label: {
                row
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(child.name))
        } else {
            row
        }
    }
}
