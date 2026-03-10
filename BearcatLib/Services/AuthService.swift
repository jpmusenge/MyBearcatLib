//
//  AuthService.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/9/26.
//

// PURPOSE: Firebase Authentication wrapper — protocol-based for testability

// NOTE: Requires Firebase Auth SPM dependency.
// In Xcode: File > Add Package Dependencies > https://github.com/firebase/firebase-ios-sdk
// Add "FirebaseAuth" product to your target.

import Foundation
import FirebaseAuth

// MARK: - Protocol

protocol AuthServiceProtocol {
    var currentUser: FirebaseAuth.User? { get }
    func signIn(email: String, password: String) async throws
    func createAccount(email: String, password: String, displayName: String) async throws
    func signOut() throws
    func sendPasswordReset(email: String) async throws
    func addAuthStateListener(_ handler: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle)
}

// MARK: - Firebase Implementation

final class FirebaseAuthService: AuthServiceProtocol {

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func createAccount(email: String, password: String, displayName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func addAuthStateListener(_ handler: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            handler(user)
        }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
