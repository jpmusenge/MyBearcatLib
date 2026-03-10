//
//  ForgotPasswordView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/9/26.
//

// PURPOSE: Password reset screen — sends Firebase reset email to @rustcollege.edu address

import SwiftUI

struct ForgotPasswordView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settings: AppSettings

    @FocusState private var emailFocused: Bool

    private var dk: Bool { settings.isDarkMode }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {

                // MARK: - Gradient Header
                gradientHeader

                // MARK: - Title
                VStack(spacing: 8) {
                    Text("Reset Password")
                        .font(Theme.Fonts.title)
                        .foregroundColor(AdaptiveColors.textPrimary(dk))

                    Text("Enter your @rustcollege.edu email and\nwe'll send you a reset link")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(AdaptiveColors.textSecondary(dk))
                        .multilineTextAlignment(.center)
                }

                // MARK: - Error Banner
                errorBanner

                if authViewModel.resetEmailSent {
                    // MARK: - Success State
                    successCard
                } else {
                    // MARK: - Form Card
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(Theme.Fonts.subheadline)
                                .foregroundColor(AdaptiveColors.textSecondary(dk))

                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Theme.Colors.primary)
                                    .frame(width: 20)

                                TextField("yourname@rustcollege.edu", text: $authViewModel.resetEmail)
                                    .font(Theme.Fonts.body)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($emailFocused)
                            }
                            .padding(Theme.Layout.paddingMedium)
                            .background(AdaptiveColors.surfaceSecondary(dk))
                            .cornerRadius(Theme.Layout.cornerRadius)

                            if !authViewModel.resetEmail.isEmpty && !authViewModel.isValidResetEmail {
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
                    }
                    .padding(Theme.Layout.paddingLarge)
                    .background(AdaptiveColors.surface(dk))
                    .cornerRadius(Theme.Layout.cornerRadius)
                    .shadow(color: AdaptiveColors.cardShadow(dk), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
                    .padding(.horizontal, Theme.Layout.paddingLarge)

                    // MARK: - Send Reset Button
                    Button(action: {
                        emailFocused = false
                        authViewModel.sendPasswordReset()
                    }) {
                        HStack(spacing: 8) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Send Reset Link")
                                    .font(Theme.Fonts.headline)
                            }
                        }
                        .foregroundColor(Theme.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                .fill(authViewModel.isValidResetEmail ? Theme.Colors.primary : Theme.Colors.textSecondary.opacity(0.4))
                        )
                        .shadow(color: authViewModel.isValidResetEmail ? Theme.Colors.primary.opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
                    }
                    .disabled(!authViewModel.isValidResetEmail || authViewModel.isLoading)
                    .padding(.horizontal, Theme.Layout.paddingLarge)
                }

                // MARK: - Back to Sign In
                Button(action: {
                    authViewModel.switchToLogin()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Back to Sign In")
                            .font(.custom("AvenirNext-DemiBold", size: 14))
                    }
                    .foregroundColor(Theme.Colors.primary)
                }

                Spacer().frame(height: 40)
            }
            .padding(.top, 16)
        }
        .background(AdaptiveColors.background(dk).ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: authViewModel.showError)
        .animation(.easeInOut(duration: 0.3), value: authViewModel.resetEmailSent)
    }

    // MARK: - Gradient Header

    private var gradientHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "lock.rotation")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text("BearcatLib")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
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

    // MARK: - Success Card

    private var successCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.success.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.Colors.success)
            }

            Text("Check Your Email")
                .font(Theme.Fonts.title2)
                .foregroundColor(AdaptiveColors.textPrimary(dk))

            Text("We've sent a password reset link to\n\(authViewModel.resetEmail)")
                .font(Theme.Fonts.subheadline)
                .foregroundColor(AdaptiveColors.textSecondary(dk))
                .multilineTextAlignment(.center)

            Text("Check your inbox and follow the link to reset your password.")
                .font(Theme.Fonts.caption)
                .foregroundColor(AdaptiveColors.textSecondary(dk))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(Theme.Layout.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(AdaptiveColors.surface(dk))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: AdaptiveColors.cardShadow(dk), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
        .padding(.horizontal, Theme.Layout.paddingLarge)
        .transition(.scale.combined(with: .opacity))
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
    ForgotPasswordView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppSettings())
}
