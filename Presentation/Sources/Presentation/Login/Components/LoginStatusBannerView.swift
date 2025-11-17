import SwiftUI

struct LoginStatusBannerView: View {
    let banner: LoginViewModel.Banner

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text(banner.message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .foregroundStyle(foregroundColor)
        .padding()
        .background(background)
        .cornerRadius(12)
        .accessibilityLabel(Text(banner.message))
    }

    private var foregroundColor: Color {
        switch banner.style {
        case .success:
            Color.green
        case .error:
            Color.red
        case .info:
            Color.kidsTrackTextPrimary(for: colorScheme)
        }
    }

    private var background: Color {
        switch banner.style {
        case .success:
            Color.green.opacity(0.15)
        case .error:
            Color.red.opacity(0.15)
        case .info:
            Color.kidsTrackSurface(for: colorScheme)
        }
    }

    private var iconName: String {
        switch banner.style {
        case .success:
            "checkmark.circle.fill"
        case .error:
            "exclamationmark.triangle.fill"
        case .info:
            "info.circle.fill"
        }
    }
}

#Preview {
    VStack {
        LoginStatusBannerView(
            banner: .init(style: .success, message: "Signed in successfully")
        )
        .padding()
        LoginStatusBannerView(
            banner: .init(style: .error, message: "Wrong password")
        )
        .padding()
        LoginStatusBannerView(
            banner: .init(style: .info, message: "Info")
        )
        .padding()
    }
}
