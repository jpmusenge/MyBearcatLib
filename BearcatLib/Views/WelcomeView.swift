//
//  WelcomeView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/12/26.
//

// PURPOSE: Landing screen — the first thing users see. Logo + Sign In / Register buttons.

import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settings: AppSettings

    private var dk: Bool { settings.isDarkMode }

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // MARK: - Logo with full branding
            BearcatLibLogo(showTitle: true)

            Spacer()

            // MARK: - Action Buttons
            VStack(spacing: 14) {

                // Sign In — primary solid button
                Button(action: {
                    authViewModel.switchToLogin()
                }) {
                    Text("Sign In")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                .fill(Theme.Colors.primary)
                        )
                        .shadow(color: Theme.Colors.primary.opacity(0.25), radius: 10, x: 0, y: 4)
                }

                // Create Account — outlined secondary button
                Button(action: {
                    authViewModel.switchToRegister()
                }) {
                    Text("Create Account")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                .stroke(Theme.Colors.primary, lineWidth: 1.5)
                        )
                }
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)

            // MARK: - Footer
            VStack(spacing: 4) {
                Text("Rust College")
                    .font(.custom("AvenirNext-DemiBold", size: 12))
                    .foregroundColor(AdaptiveColors.textSecondary(dk))

                Text("Holly Springs, Mississippi · Est. 1866")
                    .font(.custom("AvenirNext-Regular", size: 11))
                    .foregroundColor(AdaptiveColors.textSecondary(dk).opacity(0.6))
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .background(AdaptiveColors.background(dk).ignoresSafeArea())
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppSettings())
}
