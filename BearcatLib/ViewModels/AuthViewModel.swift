//
//  AuthViewModel.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/9/26.
//

// PURPOSE: Central auth state management — form state, validation, Firebase integration

import SwiftUI
import Combine
import FirebaseAuth

// MARK: - Auth Flow

enum AuthFlow {
    case welcome
    case login
    case register
    case forgotPassword
}

// MARK: - ViewModel

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Auth State

    @Published var isAuthenticated = false
    @Published var isCheckingAuth = true
    @Published var currentUser: FirebaseAuth.User?

    // MARK: - Navigation

    @Published var currentFlow: AuthFlow = .welcome

    // MARK: - Login Form

    @Published var loginEmail = ""
    @Published var loginPassword = ""

    // MARK: - Register Form

    @Published var registerName = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""

    // MARK: - Forgot Password Form

    @Published var resetEmail = ""
    @Published var resetEmailSent = false

    // MARK: - UI State

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Init

    init(authService: AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
        listenForAuthChanges()
    }

    deinit {
        if let handle = authStateHandle {
            authService.removeAuthStateListener(handle)
        }
    }

    // MARK: - Auth State Listener

    private func listenForAuthChanges() {
        authStateHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                self?.isCheckingAuth = false
            }
        }
    }

    // MARK: - Validation

    private static let rustCollegeDomain = "@rustcollege.edu"

    var isValidLoginEmail: Bool {
        let email = loginEmail.lowercased().trimmingCharacters(in: .whitespaces)
        return email.hasSuffix(Self.rustCollegeDomain) && email.count > Self.rustCollegeDomain.count
    }

    var isValidRegisterEmail: Bool {
        let email = registerEmail.lowercased().trimmingCharacters(in: .whitespaces)
        return email.hasSuffix(Self.rustCollegeDomain) && email.count > Self.rustCollegeDomain.count
    }

    var isValidResetEmail: Bool {
        let email = resetEmail.lowercased().trimmingCharacters(in: .whitespaces)
        return email.hasSuffix(Self.rustCollegeDomain) && email.count > Self.rustCollegeDomain.count
    }

    var passwordsMatch: Bool {
        !registerPassword.isEmpty && registerPassword == registerConfirmPassword
    }

    var isPasswordStrong: Bool {
        registerPassword.count >= 6
    }

    var canLogin: Bool {
        !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty && !loginPassword.isEmpty
    }

    var canRegister: Bool {
        !registerName.trimmingCharacters(in: .whitespaces).isEmpty
        && isValidRegisterEmail
        && isPasswordStrong
        && passwordsMatch
    }

    // MARK: - Computed Helpers

    var userDisplayName: String {
        currentUser?.displayName ?? "Student"
    }

    var userFirstName: String {
        let parts = userDisplayName.split(separator: " ")
        return parts.first.map(String.init) ?? "Student"
    }

    var userInitials: String {
        let parts = userDisplayName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(userDisplayName.prefix(2)).uppercased()
    }

    var userEmail: String {
        currentUser?.email ?? ""
    }

    // MARK: - Actions

    func signIn() {
        guard canLogin else { return }

        let email = loginEmail.lowercased().trimmingCharacters(in: .whitespaces)
        guard email.hasSuffix(Self.rustCollegeDomain) else {
            presentError("Please use your @rustcollege.edu email address.")
            return
        }

        isLoading = true
        errorMessage = nil
        showError = false

        Task {
            do {
                try await authService.signIn(email: email, password: loginPassword)
                clearLoginForm()
            } catch {
                presentError(mapFirebaseError(error))
            }
            isLoading = false
        }
    }

    func createAccount() {
        guard canRegister else { return }

        isLoading = true
        errorMessage = nil
        showError = false

        let name = registerName.trimmingCharacters(in: .whitespaces)
        let email = registerEmail.lowercased().trimmingCharacters(in: .whitespaces)

        Task {
            do {
                try await authService.createAccount(
                    email: email,
                    password: registerPassword,
                    displayName: name
                )
                clearRegisterForm()
            } catch {
                presentError(mapFirebaseError(error))
            }
            isLoading = false
        }
    }

    func sendPasswordReset() {
        let email = resetEmail.lowercased().trimmingCharacters(in: .whitespaces)

        guard email.hasSuffix(Self.rustCollegeDomain) else {
            presentError("Please use your @rustcollege.edu email address.")
            return
        }

        isLoading = true
        errorMessage = nil
        showError = false

        Task {
            do {
                try await authService.sendPasswordReset(email: email)
                resetEmailSent = true
            } catch {
                presentError(mapFirebaseError(error))
            }
            isLoading = false
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            clearAllForms()
        } catch {
            presentError("Failed to sign out. Please try again.")
        }
    }

    // MARK: - Navigation

    func switchToWelcome() {
        currentFlow = .welcome
        errorMessage = nil
        showError = false
    }

    func switchToLogin() {
        currentFlow = .login
        errorMessage = nil
        showError = false
    }

    func switchToRegister() {
        currentFlow = .register
        errorMessage = nil
        showError = false
    }

    func switchToForgotPassword() {
        currentFlow = .forgotPassword
        errorMessage = nil
        showError = false
        resetEmailSent = false
    }

    func dismissError() {
        showError = false
        errorMessage = nil
    }

    // MARK: - Private Helpers

    private func presentError(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
    }

    private func clearRegisterForm() {
        registerName = ""
        registerEmail = ""
        registerPassword = ""
        registerConfirmPassword = ""
    }

    private func clearAllForms() {
        clearLoginForm()
        clearRegisterForm()
        resetEmail = ""
        resetEmailSent = false
        currentFlow = .welcome
    }

    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else {
            return error.localizedDescription
        }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "No account found with this email. Please register first."
        case .emailAlreadyInUse:
            return "An account with this email already exists. Try signing in."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please wait a moment and try again."
        case .userDisabled:
            return "This account has been disabled. Contact the library for help."
        default:
            return error.localizedDescription
        }
    }
}
