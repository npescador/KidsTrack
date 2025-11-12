import SwiftUI

enum WelcomeStrings {
    static let headerTitle = LocalizedStringResource(
        "welcome.header.title",
        defaultValue: "Welcome, Sarah!",
        comment: "Main greeting shown on the welcome screen headline."
    )

    static let headerSubtitle = LocalizedStringResource(
        "welcome.header.subtitle",
        defaultValue: "Your family's command center, simplified.",
        comment: "Supporting copy shown beneath the welcome headline."
    )

    static let heroImageAccessibilityLabel = LocalizedStringResource(
        "welcome.hero.accessibility.label",
        defaultValue: "Family dashboard illustration",
        comment: "Accessibility label describing the hero image on the welcome screen."
    )

    static let getStartedButtonTitle = LocalizedStringResource(
        "welcome.cta.title",
        defaultValue: "Get Started",
        comment: "Primary call-to-action button title on the welcome screen."
    )

    static let getStartedButtonAccessibilityLabel = LocalizedStringResource(
        "welcome.cta.accessibility.label",
        defaultValue: "Begin KidsTrack onboarding",
        comment: "Accessibility label announcing the primary call-to-action button."
    )

    static let getStartedButtonAccessibilityHint = LocalizedStringResource(
        "welcome.cta.accessibility.hint",
        defaultValue: "Advances to the setup flow for your family.",
        comment: "Accessibility hint describing what happens when activating the CTA."
    )

    static let schedulesTitle = LocalizedStringResource(
        "welcome.feature.schedules.title",
        defaultValue: "Schedules",
        comment: "Feature card title referring to school and class schedules."
    )

    static let schedulesDescription = LocalizedStringResource(
        "welcome.feature.schedules.description",
        defaultValue: "Easily track school and class schedules in one place.",
        comment: "Feature card description for schedules."
    )

    static let activitiesTitle = LocalizedStringResource(
        "welcome.feature.activities.title",
        defaultValue: "Activities",
        comment: "Feature card title covering extracurricular activities."
    )

    static let activitiesDescription = LocalizedStringResource(
        "welcome.feature.activities.description",
        defaultValue: "Never miss a practice or event for extracurriculars.",
        comment: "Feature card description for activities."
    )

    static let expensesTitle = LocalizedStringResource(
        "welcome.feature.expenses.title",
        defaultValue: "Expenses",
        comment: "Feature card title covering school-related expenses."
    )

    static let expensesDescription = LocalizedStringResource(
        "welcome.feature.expenses.description",
        defaultValue: "Keep an eye on activity fees and school-related spending.",
        comment: "Feature card description for expenses."
    )
}
