import SwiftUI

public struct DeleteChildConfirmationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: DeleteChildViewModel
    private let onDeleted: () -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: DeleteChildViewModel,
        onDeleted: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDeleted = onDeleted
        self.onCancel = onCancel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("child.delete.title".localizedText())
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Text("child.delete.subtitle".localizedText())
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            if let error = viewModel.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(spacing: 12) {
                Button(role: .destructive) {
                    viewModel.delete(onDeleted: onDeleted)
                } label: {
                    if viewModel.isDeleting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("child.delete.confirm".localizedText())
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(viewModel.isDeleting)

                Button("child.delete.cancel".localizedText(), role: .cancel, action: onCancel)
                    .disabled(viewModel.isDeleting)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.kidsTrackSurface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
        )
        .padding()
    }
}
