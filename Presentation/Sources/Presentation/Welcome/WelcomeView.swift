//
//  SwiftUIView.swift
//  Presentation
//
//  Created by Ignacio Pescador Ruiz on 11/11/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let features: [Feature] = [
        Feature(
            iconSystemName: "calendar",
            title: "Schedules",
            description: "Easily track school and class schedules in one place."
        ),
        Feature(
            iconSystemName: "soccerball",
            title: "Activities",
            description: "Never miss a practice or event for extracurriculars."
        ),
        Feature(
            iconSystemName: "creditcard",
            title: "Expenses",
            description: "Keep an eye on activity fees and school-related spending."
        )
    ]

    var body: some View {
        ZStack {
            // Fondo según modo
            (colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    illustration
                    featureGrid
                    footer
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
            }
        }
        .font(.system(.body, design: .rounded))
    }

    // MARK: - Subvistas

    private var header: some View {
        VStack(spacing: 8) {
            Text("Welcome, Sarah!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .textDarkPrimary : .textLightPrimary)
                .multilineTextAlignment(.center)

            Text("Your family's command center, simplified.")
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? .textDarkSecondary : .textLightSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var illustration: some View {
        VStack {
            AsyncImage(
                url: URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuC96CuyqlxlmsaQDqQ3m0MM-go8lRZoTSQUCEPdT549WyuDzrCIELpjINlT2f_kGL25v-x8cSMDiyDquNBRzjfvX_k4NvwvdKnHHQJnzvCKh_-OFTP_BpAvU-0vKhkFYYoIxCTQ15tC0lJL5pauj1r7OVWEBAWHh1W8rZ7FidV7OeKdOUXg7qDQC7Z2n0Gc5uKVLSifHZLEmM0gX-Io5xcR3uGj2k3hj4scC-nnUEDQM71DODwDA4rsVkyYrjyIqa4NUTvkWVn5ow9H")
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 220, height: 220)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 260)
                case .failure:
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 220, height: 220)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var featureGrid: some View {
        VStack(spacing: 12) {
            ForEach(features) { feature in
                FeatureCard(feature: feature)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 24) {
            Button(action: {
                // TODO: Action "Get Started"
            }) {
                Text("Get Started")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4, y: 2)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Modelo + Tarjeta

struct Feature: Identifiable {
    let id = UUID()
    let iconSystemName: String
    let title: String
    let description: String
}

struct FeatureCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let feature: Feature

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: feature.iconSystemName)
                    .font(.system(size: 22))
                    .foregroundColor(.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .textDarkPrimary : .textLightPrimary)

                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? .textDarkSecondary : .textLightSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(colorScheme == .dark ? Color.cardDark : Color.cardLight)
        .cornerRadius(12)
    }
}

// MARK: - Colores equivalentes a tu Tailwind

extension Color {
    /// #4A90E2
    static let primaryBlue = Color(red: 0.2902, green: 0.5647, blue: 0.8863)

    /// #f6f7f8
    static let backgroundLight = Color(red: 0.9647, green: 0.9686, blue: 0.9725)
    /// #101922
    static let backgroundDark = Color(red: 0.0627, green: 0.0980, blue: 0.1333)

    /// #ffffff
    static let cardLight = Color.white
    /// #1c2127
    static let cardDark = Color(red: 0.1098, green: 0.1294, blue: 0.1529)

    /// #1f2937
    static let textLightPrimary = Color(red: 0.1216, green: 0.1608, blue: 0.2157)
    /// #f9fafb
    static let textDarkPrimary = Color(red: 0.9765, green: 0.9804, blue: 0.9843)

    /// #6b7280
    static let textLightSecondary = Color(red: 0.4196, green: 0.4471, blue: 0.5020)
    /// #9dabb9
    static let textDarkSecondary = Color(red: 0.6157, green: 0.6706, blue: 0.7255)
}

// MARK: - Preview

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView()
                .preferredColorScheme(.light)

            WelcomeView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    WelcomeView()
}
