import Shared
import SwiftUI

public struct CreateFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: CreateFamilyViewModel
    private let onCreated: (Family) -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: CreateFamilyViewModel,
        onCreated: @escaping (Family) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCreated = onCreated
        self.onCancel = onCancel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Family name")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                TextField("The Pescador Family", text: $viewModel.name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.kidsTrackSurface(for: colorScheme))
                    .cornerRadius(12)
            }

            if let banner = viewModel.banner {
                HStack(spacing: 12) {
                    Image(systemName: banner.isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundStyle(banner.isError ? Color.red : Color.green)
                    Text(banner.message)
                        .foregroundStyle(banner.isError ? Color.red : Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.kidsTrackSurface(for: colorScheme))
                .cornerRadius(12)
                .transition(.opacity)
            }

            Button(action: viewModel.createFamily) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Create family")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .background(viewModel.isCreateDisabled ? Color.gray.opacity(0.3) : Color.accentColor)
                .foregroundStyle(viewModel.isCreateDisabled ? Color.gray : Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isCreateDisabled)

            Button(role: .cancel) {
                onCancel()
                dismiss()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
        .navigationTitle("Create family")
        .onChange(of: viewModel.createdFamily) { _, family in
            if let family {
                onCreated(family)
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateFamilyView(
            viewModel: CreateFamilyViewModel(
                createFamilyUseCase: .init(
                    repository: PreviewFamilyRepository(),
                    activeStore: PreviewActiveFamilyStore()
                ),
                sessionProvider: PreviewUserSessionProvider()
            )
        )
    }
}
