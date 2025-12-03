import SwiftUI

public struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let features = WelcomeFeature.defaultFeatures
    private let heroImageURL = URL(
        string:
            """
            https://lh3.googleusercontent.com/aida-public/AB6AXuC96CuyqlxlmsaQDqQ3m0MM-
            go8lRZoTSQUCEPdT549WyuDzrCIELpjINlT2f_kGL25v
            -x8cSMDiyDquNBRzjfvX_k4NvwvdKnHHQJnzvCKh_-OFTP_BpAvU-0vKhkFYYoIxCTQ15tC0lJL5pauj1r7OVWEBAWHh1W8rZ7FidV7
            OeKdOUXg7qDQC7Z2n0Gc5uKVLSifHZLEmM0gX-Io5xcR3uGj2k3hj4scC-nnUEDQM71DODwDA4rsVkyYrjyIqa4NUTvkWVn5ow9H
            """
            .replacingOccurrences(of: "\n", with: "")
    )

    private let onGetStarted: () -> Void

    public init(onGetStarted: @escaping () -> Void = {}) {
        self.onGetStarted = onGetStarted
    }

    public var body: some View {
        ZStack {
            Color.kidsTrackBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    hero
                    featuresSection
                    footer
                }
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 32)
            .contentMargins(.vertical, 32)
        }
        .font(.system(.body, design: .rounded))
    }
}

private extension WelcomeView {
    var header: some View {
        VStack(spacing: 8) {
            Text("welcome.header.title".localizedText())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
                .accessibilityAddTraits(.isHeader)

            Text("welcome.header.subtitle".localizedText())
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    var hero: some View {
        AsyncImage(url: heroImageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 220, height: 220)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            case .failure:
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 220, height: 220)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(Text("welcome.hero.accessibility.label".localizedText()))
        .accessibilityHidden(heroImageURL == nil)
    }

    var featuresSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(features) { feature in
                WelcomeFeatureCardView(feature: feature)
            }
        }
        .accessibilityElement(children: .contain)
    }

    var footer: some View {
        VStack(spacing: 16) {
            Button {
                onGetStarted()
            } label: {
                Text("welcome.cta.title".localizedText())
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .background(Color.kidsTrackPrimaryBlue)
                    .foregroundStyle(Color.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .shadow(radius: 4, y: 2)
            .accessibilityLabel(Text("welcome.cta.accessibility.label".localizedText()))
            .accessibilityHint(Text("welcome.cta.accessibility.hint".localizedText()))
        }
        .padding(.bottom, 8)
    }
}

#Preview("Welcome • Light", traits: .fixedLayout(width: 430, height: 932)) {
    WelcomeView()
        .preferredColorScheme(.light)
}

#Preview("Welcome • Dark", traits: .fixedLayout(width: 430, height: 932)) {
    WelcomeView()
        .preferredColorScheme(.dark)
}
