//
//  BearcatLibApp.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/15/26.
//

// NOTE: Requires GoogleService-Info.plist in the project root.
// Download from Firebase Console > Project Settings > iOS app.

import SwiftUI
import Combine
import FirebaseCore

@main
struct BearcatLibApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var bookService = BookService.shared
    @StateObject private var checkoutService = CheckoutService.shared

    /// Tracks checkout changes to reschedule reminders
    @State private var checkoutCancellable: AnyCancellable?

    init() {
        FirebaseApp.configure()
        // Register notification actions (Renew / View)
        NotificationService.shared.registerCategories()
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
                        .environmentObject(bookService)
                        .environmentObject(checkoutService)
                        .onAppear {
                            bookService.startListening()
                            checkoutService.startListening()

                            // Request notification permission on first sign-in
                            if settings.notificationsEnabled {
                                NotificationService.shared.requestPermission()
                            }
                        }
                        .onReceive(checkoutService.$userCheckouts) { checkouts in
                            // Reschedule reminders whenever checkouts change
                            NotificationService.shared.scheduleReminders(
                                for: checkouts,
                                enabled: settings.notificationsEnabled
                            )
                        }
                } else {
                    authFlowView
                        .environmentObject(settings)
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: authViewModel.isCheckingAuth)
            .onChange(of: authViewModel.isAuthenticated) { _, isAuth in
                if !isAuth {
                    bookService.stopListening()
                    checkoutService.stopListening()
                    NotificationService.shared.clearAllReminders()
                }
            }
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
