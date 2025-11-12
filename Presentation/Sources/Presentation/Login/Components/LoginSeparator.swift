import SwiftUI

struct LoginSeparator: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            separatorLine
            Text(LoginStrings.dividerText)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
            separatorLine
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(LoginStrings.dividerText)
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(Color.kidsTrackBorder(for: colorScheme))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Login Separator") {
    LoginSeparator()
        .padding()
        .background(Color.kidsTrackBackground(for: .light))
}
