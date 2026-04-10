//
//  ReservationService.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 4/9/26.
//

// PURPOSE: Manages book reservations / holds in Firestore
// - Students can reserve a checked-out book to join a waitlist
// - When the book is returned, the first person in the queue gets a 48-hour hold
// - Push notification sent when a reserved book becomes available

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class ReservationService: ObservableObject {

    // MARK: - Singleton
    static let shared = ReservationService()

    // MARK: - Published State
    @Published var userReservations: [Reservation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private
    private let db = Firestore.firestore()
    private let collectionName = "reservations"
    private var listener: ListenerRegistration?
    private let holdDurationHours = 48

    private init() {}

    // MARK: - Current User ID

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Listener Lifecycle

    /// Start listening to the current user's active reservations.
    func startListening() {
        guard let userId = currentUserId else { return }
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        listener = db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("status", in: [
                ReservationStatus.waiting.rawValue,
                ReservationStatus.ready.rawValue
            ])
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load reservations: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.userReservations = []
                    return
                }

                self.userReservations = documents.compactMap { doc in
                    self.parseReservation(from: doc)
                }.sorted { $0.reservedDate < $1.reservedDate }
            }
    }

    /// Stop listening. Call on sign-out.
    func stopListening() {
        listener?.remove()
        listener = nil
        userReservations = []
    }

    // MARK: - Reserve a Book

    /// Places a hold/reservation on a checked-out book.
    func reserveBook(_ book: Book) async throws {
        guard let userId = currentUserId else {
            throw ReservationError.notSignedIn
        }
        guard let bookId = book.firestoreId else {
            throw ReservationError.missingBookId
        }

        // Check if user already has an active reservation for this book
        let existing = try await db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("bookFirestoreId", isEqualTo: bookId)
            .whereField("status", in: [
                ReservationStatus.waiting.rawValue,
                ReservationStatus.ready.rawValue
            ])
            .getDocuments()

        if !existing.documents.isEmpty {
            throw ReservationError.alreadyReserved
        }

        // Check if user already has this book checked out
        let checkouts = try await db.collection("checkouts")
            .whereField("userId", isEqualTo: userId)
            .whereField("bookFirestoreId", isEqualTo: bookId)
            .whereField("isReturned", isEqualTo: false)
            .getDocuments()

        if !checkouts.documents.isEmpty {
            throw ReservationError.alreadyCheckedOut
        }

        // Determine queue position (count existing waiting reservations for this book)
        let waitingCount = try await db.collection(collectionName)
            .whereField("bookFirestoreId", isEqualTo: bookId)
            .whereField("status", isEqualTo: ReservationStatus.waiting.rawValue)
            .getDocuments()

        let queuePosition = waitingCount.documents.count + 1

        let reservationData: [String: Any] = [
            "userId": userId,
            "bookFirestoreId": bookId,
            "title": book.title,
            "author": book.author,
            "isbn": book.isbn,
            "reservedDate": Timestamp(date: Date()),
            "expiresAt": NSNull(),
            "status": ReservationStatus.waiting.rawValue,
            "queuePosition": queuePosition
        ]

        try await db.collection(collectionName).addDocument(data: reservationData)
    }

    // MARK: - Cancel Reservation

    /// Cancels a reservation and updates queue positions for others.
    func cancelReservation(_ reservation: Reservation) async throws {
        let batch = db.batch()

        // Mark this reservation as cancelled
        let reservationRef = db.collection(collectionName).document(reservation.id)
        batch.updateData(["status": ReservationStatus.cancelled.rawValue], forDocument: reservationRef)

        try await batch.commit()

        // Reorder queue positions for remaining waiters
        try await reorderQueue(forBook: reservation.bookFirestoreId)
    }

    // MARK: - Check if User Has Reservation

    /// Returns the user's active reservation for a specific book, if any.
    func activeReservation(forBookId bookId: String) -> Reservation? {
        userReservations.first { $0.bookFirestoreId == bookId }
    }

    // MARK: - Queue Count

    /// Returns the number of people waiting for a specific book.
    func waitlistCount(forBookId bookId: String) -> Int {
        // This is a local count from user's perspective; for global count we'd need a separate query
        // For now, return from user's reservation queuePosition
        if let reservation = activeReservation(forBookId: bookId) {
            return reservation.queuePosition
        }
        return 0
    }

    /// Fetch the total waitlist count for a book from Firestore.
    func fetchWaitlistCount(forBookId bookId: String) async -> Int {
        do {
            let docs = try await db.collection(collectionName)
                .whereField("bookFirestoreId", isEqualTo: bookId)
                .whereField("status", isEqualTo: ReservationStatus.waiting.rawValue)
                .getDocuments()
            return docs.documents.count
        } catch {
            return 0
        }
    }

    // MARK: - Queue Reordering

    /// Reorders queue positions after a cancellation or fulfillment.
    private func reorderQueue(forBook bookId: String) async throws {
        let docs = try await db.collection(collectionName)
            .whereField("bookFirestoreId", isEqualTo: bookId)
            .whereField("status", isEqualTo: ReservationStatus.waiting.rawValue)
            .order(by: "reservedDate")
            .getDocuments()

        let batch = db.batch()
        for (index, doc) in docs.documents.enumerated() {
            let ref = db.collection(collectionName).document(doc.documentID)
            batch.updateData(["queuePosition": index + 1], forDocument: ref)
        }
        try await batch.commit()
    }

    // MARK: - Document Parsing

    private func parseReservation(from doc: QueryDocumentSnapshot) -> Reservation? {
        let data = doc.data()

        guard let userId = data["userId"] as? String,
              let bookFirestoreId = data["bookFirestoreId"] as? String,
              let title = data["title"] as? String else {
            return nil
        }

        let author = data["author"] as? String ?? "Unknown Author"
        let isbn = data["isbn"] as? String ?? ""
        let reservedDate = (data["reservedDate"] as? Timestamp)?.dateValue() ?? Date()
        let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue()
        let statusRaw = data["status"] as? String ?? ReservationStatus.waiting.rawValue
        let status = ReservationStatus(rawValue: statusRaw) ?? .waiting
        let queuePosition = data["queuePosition"] as? Int ?? 1

        return Reservation(
            id: doc.documentID,
            userId: userId,
            bookFirestoreId: bookFirestoreId,
            title: title,
            author: author,
            isbn: isbn,
            reservedDate: reservedDate,
            expiresAt: expiresAt,
            status: status,
            queuePosition: queuePosition
        )
    }
}

// MARK: - Errors

enum ReservationError: LocalizedError {
    case notSignedIn
    case missingBookId
    case alreadyReserved
    case alreadyCheckedOut
    case bookAvailable

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "You must be signed in to reserve books."
        case .missingBookId: return "Unable to identify this book."
        case .alreadyReserved: return "You already have a reservation for this book."
        case .alreadyCheckedOut: return "You already have this book checked out."
        case .bookAvailable: return "This book is available — you can check it out directly."
        }
    }
}
