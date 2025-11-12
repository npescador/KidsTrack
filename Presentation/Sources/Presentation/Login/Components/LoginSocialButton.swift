import SwiftUI

struct LoginSocialButton: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: LocalizedStringResource
    let accessibilityHint: LocalizedStringResource?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                providerGlyph
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                Color.kidsTrackSurface(for: colorScheme),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
        .accessibilityLabel(title)
        .accessibilityHint(Text(accessibilityHint ?? title))
    }

    private var providerGlyph: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .stroke(Color.kidsTrackBorder(for: colorScheme).opacity(0.4), lineWidth: 0.7)
                )

            Text("G")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Login Social Button") {
    LoginSocialButton(
        title: LoginStrings.googleButtonTitle,
        accessibilityHint: LoginStrings.googleButtonAccessibilityHint,
        action: {}
    )
    .padding()
    .background(Color.kidsTrackBackground(for: .light))
}
