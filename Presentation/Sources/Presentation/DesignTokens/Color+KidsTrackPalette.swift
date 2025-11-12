import SwiftUI

extension Color {
    static let kidsTrackPrimaryBlue = Color(red: 0.2902, green: 0.5647, blue: 0.8863) // #4A90E2
    static let kidsTrackBackgroundLight = Color(red: 0.9647, green: 0.9686, blue: 0.9725) // #F6F7F8
    static let kidsTrackBackgroundDark = Color(red: 0.0627, green: 0.0980, blue: 0.1333) // #101922
    static let kidsTrackCardLight = Color.white
    static let kidsTrackCardDark = Color(red: 0.1098, green: 0.1294, blue: 0.1529) // #1C2127
    static let kidsTrackSurfaceLight = Color.white // Slate-50
    static let kidsTrackSurfaceDark = Color(red: 0.1176, green: 0.1608, blue: 0.2314) // #1E293B
    static let kidsTrackBorderLight = Color(red: 0.7961, green: 0.8353, blue: 0.8824) // #CBD5E1
    static let kidsTrackBorderDark = Color(red: 0.2941, green: 0.3333, blue: 0.3882) // #4B5563
    static let kidsTrackIconMutedLight = Color(red: 0.3922, green: 0.4549, blue: 0.5451) // #64748B
    static let kidsTrackIconMutedDark = Color(red: 0.5804, green: 0.6392, blue: 0.7216) // #94A3B8
    static let kidsTrackTextLightPrimary = Color(red: 0.1216, green: 0.1608, blue: 0.2157) // #1F2937
    static let kidsTrackTextDarkPrimary = Color(red: 0.9765, green: 0.9804, blue: 0.9843) // #F9FAFB
    static let kidsTrackTextLightSecondary = Color(red: 0.4196, green: 0.4471, blue: 0.5020) // #6B7280
    static let kidsTrackTextDarkSecondary = Color(red: 0.6157, green: 0.6706, blue: 0.7255) // #9DABB9

    static func kidsTrackBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackBackgroundDark : .kidsTrackBackgroundLight
    }

    static func kidsTrackCard(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackCardDark : .kidsTrackCardLight
    }

    static func kidsTrackSurface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackSurfaceDark : .kidsTrackSurfaceLight
    }

    static func kidsTrackBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackBorderDark : .kidsTrackBorderLight
    }

    static func kidsTrackTextPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackTextDarkPrimary : .kidsTrackTextLightPrimary
    }

    static func kidsTrackTextSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackTextDarkSecondary : .kidsTrackTextLightSecondary
    }

    static func kidsTrackIconMuted(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .kidsTrackIconMutedDark : .kidsTrackIconMutedLight
    }
}
