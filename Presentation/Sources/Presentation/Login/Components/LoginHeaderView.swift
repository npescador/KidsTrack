import SwiftUI

struct LoginHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            emblem
            titles
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private extension LoginHeaderView {
    var emblem: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.kidsTrackPrimaryBlue.opacity(0.15))
                .frame(width: 64, height: 64)

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.kidsTrackPrimaryBlue)
        }
        .accessibilityHidden(true)
    }

    var titles: some View {
        VStack(spacing: 8) {
            Text("login.header.title".localized())
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))

            Text("login.header.subtitle".localized())
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
        }
    }
}

#Preview("Login Header") {
    LoginHeaderView()
        .padding()
        .background(Color.kidsTrackBackground(for: .light))
}
