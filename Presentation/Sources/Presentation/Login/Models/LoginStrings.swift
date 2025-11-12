import SwiftUI

enum LoginStrings {
    static let headerTitle = LocalizedStringResource(
        "login.header.title",
        defaultValue: "Welcome back!",
        comment: "Primary headline shown on the login screen."
    )

    static let headerSubtitle = LocalizedStringResource(
        "login.header.subtitle",
        defaultValue: "Log in to manage your family's schedule.",
        comment: "Supporting text beneath the login headline."
    )

    static let emailLabel = LocalizedStringResource(
        "login.form.email.label",
        defaultValue: "Email",
        comment: "Label for the email text field on the login screen."
    )

    static let emailPlaceholder = LocalizedStringResource(
        "login.form.email.placeholder",
        defaultValue: "Enter your email",
        comment: "Placeholder for the email text field."
    )

    static let passwordLabel = LocalizedStringResource(
        "login.form.password.label",
        defaultValue: "Password",
        comment: "Label for the password text field on the login screen."
    )

    static let passwordPlaceholder = LocalizedStringResource(
        "login.form.password.placeholder",
        defaultValue: "Enter your password",
        comment: "Placeholder for the password text field."
    )

    static let forgotPasswordAction = LocalizedStringResource(
        "login.form.password.forgot",
        defaultValue: "Forgot Password?",
        comment: "Action to trigger password recovery."
    )

    static let showPasswordLabel = LocalizedStringResource(
        "login.form.password.show",
        defaultValue: "Show password",
        comment: "Accessibility label for toggling password visibility."
    )

    static let hidePasswordLabel = LocalizedStringResource(
        "login.form.password.hide",
        defaultValue: "Hide password",
        comment: "Accessibility label for toggling password visibility off."
    )

    static let loginButtonTitle = LocalizedStringResource(
        "login.form.primary.cta",
        defaultValue: "Log In",
        comment: "Primary CTA title for the login form submission."
    )

    static let loginButtonAccessibilityHint = LocalizedStringResource(
        "login.form.primary.cta.hint",
        defaultValue: "Attempts to authenticate with the provided credentials.",
        comment: "Accessibility hint explaining what the login button does."
    )

    static let dividerText = LocalizedStringResource(
        "login.divider.text",
        defaultValue: "OR",
        comment: "Text displayed between the login form and social logins."
    )

    static let googleButtonTitle = LocalizedStringResource(
        "login.social.google.title",
        defaultValue: "Continue with Google",
        comment: "Button title for Google social login."
    )

    static let googleButtonAccessibilityHint = LocalizedStringResource(
        "login.social.google.hint",
        defaultValue: "Opens Google sign-in to authenticate.",
        comment: "Accessibility hint for the Google login button."
    )

    static let signupPrompt = LocalizedStringResource(
        "login.signup.prompt",
        defaultValue: "Don't have an account?",
        comment: "Text shown before the Sign Up CTA on the login screen."
    )

    static let signupAction = LocalizedStringResource(
        "login.signup.cta",
        defaultValue: "Sign Up",
        comment: "Button title encouraging users to create an account."
    )
}
