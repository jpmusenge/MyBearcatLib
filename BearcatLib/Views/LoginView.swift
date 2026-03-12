//
//  LoginView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/9/26.
//

// PURPOSE: Login screen — email/password sign-in with @rustcollege.edu validation

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settings: AppSettings

    @FocusState private var focusedField: Field?

    private var dk: Bool { settings.isDarkMode }

    private enum Field {
        case email, password
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {

                // MARK: - Logo
                BearcatLibLogo(showTitle: false)
                    .scaleEffect(0.6)
                    .padding(.top, 16)

                // MARK: - Welcome Text
                VStack(spacing: 6) {
                    Text("Welcome Back")
                        .font(Theme.Fonts.title)
                        .foregroundColor(AdaptiveColors.textPrimary(dk))

                    Text("Sign in with your Rust College email")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(AdaptiveColors.textSecondary(dk))
                }

                // MARK: - Error Banner
                errorBanner

                // MARK: - Form Card
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))

                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 20)

                            TextField("yourname@rustcollege.edu", text: $authViewModel.loginEmail)
                                .font(Theme.Fonts.body)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                        }
                        .padding(Theme.Layout.paddingMedium)
                        .background(AdaptiveColors.surfaceSecondary(dk))
                        .cornerRadius(Theme.Layout.cornerRadius)

                        // Inline email validation hint
                        if !authViewModel.loginEmail.isEmpty && !authViewModel.isValidLoginEmail {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Must be a @rustcollege.edu email")
                                    .font(Theme.Fonts.caption)
                            }
                            .foregroundColor(Theme.Colors.error)
                            .transition(.opacity)
                        }
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 20)

                            SecureField("Enter your password", text: $authViewModel.loginPassword)
                                .font(Theme.Fonts.body)
                                .focused($focusedField, equals: .password)
                        }
                        .padding(Theme.Layout.paddingMedium)
                        .background(AdaptiveColors.surfaceSecondary(dk))
                        .cornerRadius(Theme.Layout.cornerRadius)
                    }

                    // Forgot Password Link
                    HStack {
                        Spacer()
                        Button(action: {
                            authViewModel.switchToForgotPassword()
                        }) {
                            Text("Forgot Password?")
                                .font(Theme.Fonts.subheadline)
                                .foregroundColor(Theme.Colors.accent)
                        }
                    }
                }
                .padding(Theme.Layout.paddingLarge)
                .background(AdaptiveColors.surface(dk))
                .cornerRadius(Theme.Layout.cornerRadius)
                .shadow(color: AdaptiveColors.cardShadow(dk), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
                .padding(.horizontal, Theme.Layout.paddingLarge)

                // MARK: - Sign In Button
                Button(action: {
                    focusedField = nil
                    authViewModel.signIn()
                }) {
                    HStack(spacing: 8) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .font(Theme.Fonts.headline)
                        }
                    }
                    .foregroundColor(Theme.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                            .fill(authViewModel.canLogin ? Theme.Colors.primary : Theme.Colors.textSecondary.opacity(0.4))
                    )
                    .shadow(color: authViewModel.canLogin ? Theme.Colors.primary.opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
                }
                .disabled(!authViewModel.canLogin || authViewModel.isLoading)
                .padding(.horizontal, Theme.Layout.paddingLarge)

                // MARK: - Register Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(AdaptiveColors.textSecondary(dk))

                    Button(action: {
                        authViewModel.switchToRegister()
                    }) {
                        Text("Register")
                            .font(.custom("AvenirNext-DemiBold", size: 14))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                Spacer().frame(height: 40)
            }
            .padding(.top, 16)
        }
        .background(AdaptiveColors.background(dk).ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: authViewModel.showError)
        .animation(.easeInOut(duration: 0.2), value: authViewModel.isValidLoginEmail)
    }

    // MARK: - Error Banner

    @ViewBuilder
    private var errorBanner: some View {
        if authViewModel.showError, let message = authViewModel.errorMessage {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Theme.Colors.error)

                Text(message)
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(Theme.Colors.error)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: { authViewModel.dismissError() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.Colors.error.opacity(0.5))
                }
            }
            .padding(Theme.Layout.paddingMedium)
            .background(Theme.Colors.error.opacity(0.08))
            .cornerRadius(Theme.Layout.cornerRadius)
            .padding(.horizontal, Theme.Layout.paddingLarge)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppSettings())
}
