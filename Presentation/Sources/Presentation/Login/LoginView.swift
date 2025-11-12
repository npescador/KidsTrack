//
//  SwiftUIView.swift
//  Presentation
//
//  Created by Ignacio Pescador Ruiz on 11/11/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        ZStack {
            // Fondo
            (colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            ScrollView {
                VStack {
                    Spacer(minLength: 40)

                    content
                        .padding(.horizontal, 40)

                    Spacer(minLength: 40)
                }
            }
        }
        .font(.system(.body, design: .rounded))
    }

    private var content: some View {
        VStack(spacing: 24) {
            header
            form
            separator
            socialButtons
            signupCTA
        }
        .frame(maxWidth: 400) // similar a max-w-sm
        .padding(.vertical, 24)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.primaryBlue.opacity(0.2))
                    .frame(width: 64, height: 64)

                Image(systemName: "calendar.badge.clock") // equivalente a event_note
                    .font(.system(size: 28))
                    .foregroundColor(.primaryBlue)
            }
            .padding(.bottom, 8)

            Text("Welcome back!")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : Color(.sRGB, red: 15/255, green: 23/255, blue: 42/255, opacity: 1)) // slate-900

            Text("Log in to manage your family's schedule.")
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark
                                 ? Color(.sRGB, red: 148/255, green: 163/255, blue: 184/255, opacity: 1) // slate-400
                                 : Color(.sRGB, red: 71/255, green: 85/255, blue: 105/255, opacity: 1)) // slate-600
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Form

    private var form: some View {
        VStack(spacing: 20) {
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colorScheme == .dark
                                     ? Color(.sRGB, red: 203/255, green: 213/255, blue: 225/255, opacity: 1) // slate-300
                                     : Color(.sRGB, red: 51/255, green: 65/255, blue: 85/255, opacity: 1)) // slate-700

                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(fieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(fieldBorder, lineWidth: 1)
                    )
                    .foregroundColor(fieldTextColor)
            }

            // Password
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colorScheme == .dark
                                         ? Color(.sRGB, red: 203/255, green: 213/255, blue: 225/255, opacity: 1)
                                         : Color(.sRGB, red: 51/255, green: 65/255, blue: 85/255, opacity: 1))

                    Spacer()

                    Button {
                        // TODO: acción "Forgot Password?"
                    } label: {
                        Text("Forgot Password?")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primaryBlue)
                    }
                }

                ZStack(alignment: .trailing) {
                    Group {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(fieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(fieldBorder, lineWidth: 1)
                    )
                    .foregroundColor(fieldTextColor)

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark
                                             ? Color(.sRGB, red: 148/255, green: 163/255, blue: 184/255, opacity: 1) // slate-400
                                             : Color(.sRGB, red: 100/255, green: 116/255, blue: 139/255, opacity: 1)) // slate-500
                            .padding(.trailing, 12)
                    }
                }
            }

            // Login Button
            Button {
                // TODO: acción Login
            } label: {
                Text("Login")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .shadow(color: Color.primaryBlue.opacity(0.25), radius: 4, y: 2)
        }
    }

    // MARK: - Separator

    private var separator: some View {
        HStack {
            Rectangle()
                .fill(separatorLineColor)
                .frame(height: 1)

            Text("OR")
                .font(.system(size: 13))
                .foregroundColor(separatorTextColor)
                .padding(.horizontal, 8)

            Rectangle()
                .fill(separatorLineColor)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Social

    private var socialButtons: some View {
        VStack(spacing: 12) {
            Button {
                // TODO: acción Google
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                            )
                            .frame(width: 22, height: 22)

                        Text("G")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                    }

                    Text("Continue with Google")
                        .font(.system(size: 14, weight: .medium))

                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(socialBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(socialBorder, lineWidth: 1)
                )
                .foregroundColor(socialText)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Sign up

    private var signupCTA: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.system(size: 13))
                .foregroundColor(colorScheme == .dark
                                 ? Color(.sRGB, red: 148/255, green: 163/255, blue: 184/255, opacity: 1)
                                 : Color(.sRGB, red: 71/255, green: 85/255, blue: 105/255, opacity: 1))

            Button {
                // TODO: acción Sign Up
            } label: {
                Text("Sign Up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .underline(false)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers colores

    private var fieldBackground: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 30/255, green: 41/255, blue: 59/255, opacity: 1) // slate-800
        : .white
    }

    private var fieldBorder: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 75/255, green: 85/255, blue: 99/255, opacity: 1) // slate-600
        : Color(.sRGB, red: 203/255, green: 213/255, blue: 225/255, opacity: 1) // slate-300
    }

    private var fieldTextColor: Color {
        colorScheme == .dark ? .white : Color(.sRGB, red: 15/255, green: 23/255, blue: 42/255, opacity: 1)
    }

    private var separatorLineColor: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 51/255, green: 65/255, blue: 85/255, opacity: 1) // slate-700
        : Color(.sRGB, red: 203/255, green: 213/255, blue: 225/255, opacity: 1)
    }

    private var separatorTextColor: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 148/255, green: 163/255, blue: 184/255, opacity: 1)
        : Color(.sRGB, red: 100/255, green: 116/255, blue: 139/255, opacity: 1)
    }

    private var socialBackground: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 30/255, green: 41/255, blue: 59/255, opacity: 1) // slate-800
        : .white
    }

    private var socialBorder: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 75/255, green: 85/255, blue: 99/255, opacity: 1)
        : Color(.sRGB, red: 203/255, green: 213/255, blue: 225/255, opacity: 1)
    }

    private var socialText: Color {
        colorScheme == .dark
        ? Color(.sRGB, red: 226/255, green: 232/255, blue: 240/255, opacity: 1) // slate-200
        : Color(.sRGB, red: 51/255, green: 65/255, blue: 85/255, opacity: 1) // slate-700
    }
}

// MARK: - Preview

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.light)

            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    LoginView()
}
