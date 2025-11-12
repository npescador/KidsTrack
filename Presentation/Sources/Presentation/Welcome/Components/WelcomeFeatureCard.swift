import SwiftUI

struct WelcomeFeatureCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let feature: WelcomeFeature

    var body: some View {
        HStack(spacing: 16) {
            icon
            copy
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            Color.kidsTrackCard(for: colorScheme),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(feature.title)
        .accessibilityHint(feature.description)
    }
}

private extension WelcomeFeatureCard {
    var icon: some View {
        ZStack {
            Circle()
                .fill(Color.kidsTrackPrimaryBlue.opacity(0.12))
                .frame(width: 48, height: 48)

            Image(systemName: feature.iconSystemName)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.kidsTrackPrimaryBlue)
        }
        .accessibilityHidden(true)
    }

    var copy: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(feature.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))

            Text(feature.description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Feature Card") {
    WelcomeFeatureCard(
        feature: .init(
            id: "preview",
            iconSystemName: "calendar",
            title: WelcomeStrings.schedulesTitle,
            description: WelcomeStrings.schedulesDescription
        )
    )
    .padding()
    .background(Color.kidsTrackBackground(for: .light))
}
