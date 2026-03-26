//
//  CheckoutService.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/26/26.
//

// PURPOSE: Manages book checkout records in Firestore — fetch, checkout, return, renew

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CheckoutService: ObservableObject {

    // MARK: - Singleton
    static let shared = CheckoutService()

    // MARK: - Published State
    @Published var userCheckouts: [Checkout] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private
    private let db = Firestore.firestore()
    private let collectionName = "checkouts"
    private var listener: ListenerRegistration?
    private let maxRenewals = 2
    private let loanDays = 14   // 2-week loan period

    private init() {}

    // MARK: - Current User ID

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Listener Lifecycle

    /// Start listening to the current user's active checkouts.
    func startListening() {
        guard let userId = currentUserId else {
            errorMessage = "Not signed in."
            return
        }
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        listener = db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("isReturned", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load checkouts: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.userCheckouts = []
                    return
                }

                self.userCheckouts = documents.compactMap { doc in
                    self.parseCheckout(from: doc)
                }
            }
    }

    /// Stop listening. Call on sign-out.
    func stopListening() {
        listener?.remove()
        listener = nil
        userCheckouts = []
    }

    // MARK: - Checkout a Book

    /// Creates a checkout record and marks the book as unavailable.
    func checkoutBook(_ book: Book) async throws {
        guard let userId = currentUserId else {
            throw CheckoutError.notSignedIn
        }
        guard book.isAvailable else {
            throw CheckoutError.bookUnavailable
        }
        guard let bookId = book.firestoreId else {
            throw CheckoutError.missingBookId
        }

        // Check if user already has this book checked out
        let existing = try await db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("bookFirestoreId", isEqualTo: bookId)
            .whereField("isReturned", isEqualTo: false)
            .getDocuments()

        if !existing.documents.isEmpty {
            throw CheckoutError.alreadyCheckedOut
        }

        let now = Date()
        let dueDate = Calendar.current.date(byAdding: .day, value: loanDays, to: now)!

        let checkoutData: [String: Any] = [
            "userId": userId,
            "bookFirestoreId": bookId,
            "title": book.title,
            "author": book.author,
            "isbn": book.isbn,
            "checkedOutDate": Timestamp(date: now),
            "dueDate": Timestamp(date: dueDate),
            "renewCount": 0,
            "isReturned": false
        ]

        // Create checkout record and update book availability in a batch
        let batch = db.batch()

        let checkoutRef = db.collection(collectionName).document()
        batch.setData(checkoutData, forDocument: checkoutRef)

        let bookRef = db.collection("books").document(bookId)
        batch.updateData(["isAvailable": false], forDocument: bookRef)

        try await batch.commit()
    }

    // MARK: - Return a Book

    /// Marks a checkout as returned and the book as available.
    func returnBook(_ checkout: Checkout) async throws {
        let batch = db.batch()

        let checkoutRef = db.collection(collectionName).document(checkout.id)
        batch.updateData(["isReturned": true], forDocument: checkoutRef)

        let bookRef = db.collection("books").document(checkout.bookFirestoreId)
        batch.updateData(["isAvailable": true], forDocument: bookRef)

        try await batch.commit()
    }

    // MARK: - Renew a Book

    /// Extends the due date by another loan period. Max 2 renewals.
    func renewBook(_ checkout: Checkout) async throws {
        guard checkout.canRenew else {
            throw CheckoutError.maxRenewalsReached
        }

        let newDueDate = Calendar.current.date(byAdding: .day, value: loanDays, to: checkout.dueDate)!

        try await db.collection(collectionName).document(checkout.id).updateData([
            "dueDate": Timestamp(date: newDueDate),
            "renewCount": checkout.renewCount + 1
        ])
    }

    // MARK: - Document Parsing

    private func parseCheckout(from doc: QueryDocumentSnapshot) -> Checkout? {
        let data = doc.data()

        guard let userId = data["userId"] as? String,
              let bookFirestoreId = data["bookFirestoreId"] as? String,
              let title = data["title"] as? String else {
            return nil
        }

        let author = data["author"] as? String ?? "Unknown Author"
        let isbn = data["isbn"] as? String ?? ""
        let renewCount = data["renewCount"] as? Int ?? 0
        let isReturned = data["isReturned"] as? Bool ?? false

        // Parse Firestore Timestamps
        let checkedOutDate = (data["checkedOutDate"] as? Timestamp)?.dateValue() ?? Date()
        let dueDate = (data["dueDate"] as? Timestamp)?.dateValue() ?? Date()

        return Checkout(
            id: doc.documentID,
            userId: userId,
            bookFirestoreId: bookFirestoreId,
            title: title,
            author: author,
            isbn: isbn,
            checkedOutDate: checkedOutDate,
            dueDate: dueDate,
            renewCount: renewCount,
            isReturned: isReturned
        )
    }

    // MARK: - Computed Helpers

    var overdueCheckouts: [Checkout] {
        userCheckouts.filter { $0.isOverdue }
    }

    var activeCheckouts: [Checkout] {
        userCheckouts.filter { !$0.isOverdue }
            .sorted { $0.daysUntilDue < $1.daysUntilDue }
    }

    var nextDueLabel: String {
        guard let next = activeCheckouts.first else { return "—" }
        let days = next.daysUntilDue
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "\(days)d"
    }
}

// MARK: - Errors

enum CheckoutError: LocalizedError {
    case notSignedIn
    case bookUnavailable
    case missingBookId
    case alreadyCheckedOut
    case maxRenewalsReached

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "You must be signed in to check out books."
        case .bookUnavailable: return "This book is currently checked out by another student."
        case .missingBookId: return "Unable to identify this book."
        case .alreadyCheckedOut: return "You already have this book checked out."
        case .maxRenewalsReached: return "Maximum renewals (2) reached. Please return the book."
        }
    }
}
