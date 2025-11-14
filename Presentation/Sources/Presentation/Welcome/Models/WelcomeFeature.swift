import SwiftUI

struct WelcomeFeature: Identifiable, Sendable {
    let id: String
    let iconSystemName: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource
}

extension WelcomeFeature {
    static let defaultFeatures: [WelcomeFeature] = [
        WelcomeFeature(
            id: "schedules",
            iconSystemName: "calendar",
            title: "welcome.feature.schedules.title".localized(),
            description: "welcome.feature.schedules.description".localized()
        ),
        WelcomeFeature(
            id: "activities",
            iconSystemName: "soccerball",
            title: "welcome.feature.activities.title".localized(),
            description: "welcome.feature.activities.description".localized()
        ),
        WelcomeFeature(
            id: "expenses",
            iconSystemName: "creditcard",
            title: "welcome.feature.expenses.title".localized(),
            description: "welcome.feature.expenses.description".localized()
        )
    ]
}
