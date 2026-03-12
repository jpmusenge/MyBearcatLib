//
//  BearcatLibApp.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/15/26.
//

// NOTE: Requires GoogleService-Info.plist in the project root.
// Download from Firebase Console > Project Settings > iOS app.

import SwiftUI
import FirebaseCore

@main
struct BearcatLibApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isCheckingAuth {
                    launchScreen
                } else if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(settings)
                        .environmentObject(authViewModel)
                } else {
                    authFlowView
                        .environmentObject(settings)
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: authViewModel.isCheckingAuth)
        }
    }

    // MARK: - Auth Flow Router

    @ViewBuilder
    private var authFlowView: some View {
        switch authViewModel.currentFlow {
        case .welcome:
            WelcomeView()
        case .login:
            LoginView()
        case .register:
            RegisterView()
        case .forgotPassword:
            ForgotPasswordView()
        }
    }

    // MARK: - Launch Screen

    private var launchScreen: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                BearcatLibLogo(showTitle: true)

                ProgressView()
                    .tint(Theme.Colors.primary)
            }
        }
    }
}
