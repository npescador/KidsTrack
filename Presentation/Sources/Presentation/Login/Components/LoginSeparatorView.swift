import SwiftUI

struct LoginSeparatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            separatorLine
            Text("login.divider.text".localized())
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
            separatorLine
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("login.divider.text".localized()))
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(Color.kidsTrackBorder(for: colorScheme))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Login Separator") {
    LoginSeparatorView()
        .padding()
        .background(Color.kidsTrackBackground(for: .light))
}
