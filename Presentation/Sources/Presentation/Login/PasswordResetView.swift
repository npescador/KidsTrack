import Domain
import SwiftUI

public struct PasswordResetView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: PasswordResetViewModel

    public init(viewModel: PasswordResetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var boundViewModel = viewModel

        ZStack {
            Color.kidsTrackBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    if let banner = boundViewModel.banner {
                        bannerView(banner)
                    }

                    form(viewModel: $boundViewModel)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .frame(maxWidth: 480)
            }
            .scrollIndicators(.hidden)

            if boundViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                    .accessibilityLabel(Text("Sending password reset…"))
            }
        }
        .font(.system(.body, design: .rounded))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
                .accessibilityLabel(Text("Go back to login"))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension PasswordResetView {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("password.reset.title".localized())
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))

            Text("password.reset.subtitle".localized())
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func bannerView(_ banner: PasswordResetViewModel.Banner) -> some View {
        HStack(spacing: 12) {
            Image(systemName: banner.style == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(banner.style == .success ? Color.green : Color.orange)
            Text(banner.message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kidsTrackSurface(for: colorScheme))
        .cornerRadius(12)
    }

    func form(viewModel: Bindable<PasswordResetViewModel>) -> some View {
        VStack(spacing: 16) {
            TextField(
                "",
                text: viewModel.email,
                prompt: Text("password.reset.email.placeholder".localized())
                    .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.emailAddress)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.kidsTrackSurface(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
            )
            .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
            .accessibilityLabel(Text("password.reset.email.label".localized()))

            Button {
                viewModel.wrappedValue.submit()
            } label: {
                Group {
                    if viewModel.wrappedValue.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("password.reset.cta".localized())
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(Color.kidsTrackPrimaryBlue)
                .foregroundStyle(Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.wrappedValue.isPrimaryDisabled)
        }
    }
}

#if DEBUG
extension PasswordResetView {
    public static func preview() -> PasswordResetView {
        PasswordResetView(
            viewModel: PasswordResetViewModel(
                resetUseCase: SendPasswordResetUseCase(repository: PreviewAuthRepository())
            )
        )
    }
}
#endif
