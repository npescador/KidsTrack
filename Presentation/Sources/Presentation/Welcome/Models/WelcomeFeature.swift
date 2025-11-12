import SwiftUI

struct WelcomeFeature: Identifiable, Sendable {
    let id: String
    let iconSystemName: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    init(
        id: String,
        iconSystemName: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource
    ) {
        self.id = id
        self.iconSystemName = iconSystemName
        self.title = title
        self.description = description
    }
}

extension WelcomeFeature {
    static let defaultFeatures: [WelcomeFeature] = [
        WelcomeFeature(
            id: "schedules",
            iconSystemName: "calendar",
            title: WelcomeStrings.schedulesTitle,
            description: WelcomeStrings.schedulesDescription
        ),
        WelcomeFeature(
            id: "activities",
            iconSystemName: "soccerball",
            title: WelcomeStrings.activitiesTitle,
            description: WelcomeStrings.activitiesDescription
        ),
        WelcomeFeature(
            id: "expenses",
            iconSystemName: "creditcard",
            title: WelcomeStrings.expensesTitle,
            description: WelcomeStrings.expensesDescription
        ),
    ]
}
