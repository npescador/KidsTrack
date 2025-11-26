import SwiftUI

public struct InviteAdultView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: InviteAdultViewModel
    private let onSent: () -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: InviteAdultViewModel,
        onSent: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSent = onSent
        self.onCancel = onCancel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("invite.title".localized())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("invite.subtitle".localized())
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("invite.email.label".localized())
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                TextField(String(localized: "invite.email.placeholder".localized()), text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.kidsTrackSurface(for: colorScheme))
                    .cornerRadius(12)
            }

            if let banner = viewModel.banner {
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

            Button {
                viewModel.send()
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("invite.action.send".localized())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(viewModel.isSubmitDisabled ? Color.gray.opacity(0.3) : Color.accentColor)
                .foregroundStyle(viewModel.isSubmitDisabled ? Color.gray : Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSubmitDisabled)

            Button(role: .cancel) {
                onCancel()
            } label: {
                Text("invite.action.cancel".localized())
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.25), value: viewModel.banner)
        .onChange(of: viewModel.didSendSuccessfully) { _, success in
            if success {
                onSent()
                viewModel.didSendSuccessfully = false
            }
        }
    }
}
