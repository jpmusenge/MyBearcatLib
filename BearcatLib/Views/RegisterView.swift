//
//  RegisterView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/9/26.
//

// PURPOSE: Registration screen — create account with @rustcollege.edu email + inline validation

import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settings: AppSettings

    @FocusState private var focusedField: Field?

    private var dk: Bool { settings.isDarkMode }

    private enum Field {
        case name, email, password, confirmPassword
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {

                // MARK: - Gradient Header
                gradientHeader

                // MARK: - Title
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(Theme.Fonts.title)
                        .foregroundColor(AdaptiveColors.textPrimary(dk))

                    Text("Use your Rust College email to get started")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(AdaptiveColors.textSecondary(dk))
                }

                // MARK: - Error Banner
                errorBanner

                // MARK: - Form Card
                VStack(spacing: 20) {

                    // Full Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))

                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 20)

                            TextField("Your full name", text: $authViewModel.registerName)
                                .font(Theme.Fonts.body)
                                .textInputAutocapitalization(.words)
                                .focused($focusedField, equals: .name)
                        }
                        .padding(Theme.Layout.paddingMedium)
                        .background(AdaptiveColors.surfaceSecondary(dk))
                        .cornerRadius(Theme.Layout.cornerRadius)
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))

                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 20)

                            TextField("yourname@rustcollege.edu", text: $authViewModel.registerEmail)
                                .font(Theme.Fonts.body)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                        }
                        .padding(Theme.Layout.paddingMedium)
                        .background(AdaptiveColors.surfaceSecondary(dk))
                        .cornerRadius(Theme.Layout.cornerRadius)

                        if !authViewModel.registerEmail.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: authViewModel.isValidRegisterEmail
                                      ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(authViewModel.isValidRegisterEmail
                                     ? "Valid Rust College email"
                                     : "Must be a @rustcollege.edu email")
                                    .font(Theme.Fonts.caption)
                            }
                            .foregroundColor(authViewModel.isValidRegisterEmail
                                             ? Theme.Colors.success : Theme.Colors.error)
                            .transition(.opacity)
                        }
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 20)

                            SecureField("Minimum 6 characters", text: $authViewModel.registerPassword)
                                .font(Theme.Fonts.body)
                                .focused($focusedField, equals: .password)
                        }
                        .padding(Theme.Layout.paddingMedium)
                        .background(AdaptiveColors.surfaceSecondary(dk))
                        .cornerRadius(Theme.Layout.cornerRadius)

                        if !authViewModel.registerPassword.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: authViewModel.isPasswordStrong
                                      ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(authViewModel.isPasswordStrong
                                     ? "Password strength: Good"
                                     : "At least 6 characters required")
                                    .font(Theme.Fonts.caption)
                            }
                            .foregroundColor(authViewModel.isPasswordStrong
                                             ? Theme.Colors.success : Theme.Colors.error)
                            .transition(.opacity)
                        }
                    }

                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 20)

                            SecureField("Re-enter your password", text: $authViewModel.registerConfirmPassword)
                                .font(Theme.Fonts.body)
                                .focused($focusedField, equals: .confirmPassword)
                        }
                        .padding(Theme.Layout.paddingMedium)
                        .background(AdaptiveColors.surfaceSecondary(dk))
                        .cornerRadius(Theme.Layout.cornerRadius)

                        if !authViewModel.registerConfirmPassword.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: authViewModel.passwordsMatch
                                      ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(authViewModel.passwordsMatch
                                     ? "Passwords match"
                                     : "Passwords don't match")
                                    .font(Theme.Fonts.caption)
                            }
                            .foregroundColor(authViewModel.passwordsMatch
                                             ? Theme.Colors.success : Theme.Colors.error)
                            .transition(.opacity)
                        }
                    }
                }
                .padding(Theme.Layout.paddingLarge)
                .background(AdaptiveColors.surface(dk))
                .cornerRadius(Theme.Layout.cornerRadius)
                .shadow(color: AdaptiveColors.cardShadow(dk), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
                .padding(.horizontal, Theme.Layout.paddingLarge)

                // MARK: - Create Account Button
                Button(action: {
                    focusedField = nil
                    authViewModel.createAccount()
                }) {
                    HStack(spacing: 8) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                                .font(Theme.Fonts.headline)
                        }
                    }
                    .foregroundColor(Theme.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                            .fill(authViewModel.canRegister ? Theme.Colors.primary : Theme.Colors.textSecondary.opacity(0.4))
                    )
                    .shadow(color: authViewModel.canRegister ? Theme.Colors.primary.opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
                }
                .disabled(!authViewModel.canRegister || authViewModel.isLoading)
                .padding(.horizontal, Theme.Layout.paddingLarge)

                // MARK: - Sign In Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(AdaptiveColors.textSecondary(dk))

                    Button(action: {
                        authViewModel.switchToLogin()
                    }) {
                        Text("Sign In")
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
        .animation(.easeInOut(duration: 0.2), value: authViewModel.isValidRegisterEmail)
        .animation(.easeInOut(duration: 0.2), value: authViewModel.isPasswordStrong)
        .animation(.easeInOut(duration: 0.2), value: authViewModel.passwordsMatch)
    }

    // MARK: - Gradient Header

    private var gradientHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text("BearcatLib")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Leontyne Price Library")
                .font(Theme.Fonts.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            LinearGradient(
                colors: [Theme.Colors.primaryLight, Theme.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 15, x: 0, y: 8)
        .padding(.horizontal, Theme.Layout.paddingLarge)
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
    RegisterView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppSettings())
}
