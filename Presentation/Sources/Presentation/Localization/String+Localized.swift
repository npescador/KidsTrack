import SwiftUI

extension String {
    /// Returns a localized string resource from the Presentation string catalog.
    func localized(comment: StaticString? = nil) -> LocalizedStringResource {
        LocalizedStringResource(
            String.LocalizationValue(self),
            table: "PresentationStrings",
            bundle: .kidsTrackPresentationModule,
            comment: comment
        )
    }
}

private extension LocalizedStringResource.BundleDescription {
    static var kidsTrackPresentationModule: LocalizedStringResource.BundleDescription {
        .atURL(Bundle.module.bundleURL)
    }
}
