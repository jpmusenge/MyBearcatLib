//
//  Reservation.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 4/9/26.
//

// PURPOSE: Represents a book reservation / hold in the waitlist queue

import Foundation

struct Reservation: Identifiable, Hashable {
    let id: String                 // Firestore document ID
    let userId: String
    let bookFirestoreId: String    // Links back to the books collection
    let title: String
    let author: String
    let isbn: String
    let reservedDate: Date
    var expiresAt: Date?           // 48-hour hold window (set when book becomes available)
    var status: ReservationStatus
    var queuePosition: Int         // Position in the waitlist (1 = next in line)

    // MARK: - Computed Properties

    var isExpired: Bool {
        guard let expires = expiresAt else { return false }
        return expires < Date()
    }

    var hoursUntilExpiry: Int? {
        guard let expires = expiresAt else { return nil }
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: expires).hour ?? 0
        return max(0, hours)
    }

    var statusText: String {
        switch status {
        case .waiting:
            return "Position #\(queuePosition) in queue"
        case .ready:
            if let hours = hoursUntilExpiry {
                return "Ready for pickup — \(hours)h left"
            }
            return "Ready for pickup"
        case .fulfilled:
            return "Checked out"
        case .cancelled:
            return "Cancelled"
        case .expired:
            return "Expired"
        }
    }
}

// MARK: - Reservation Status

enum ReservationStatus: String, Codable {
    case waiting    // In the queue, book not yet available
    case ready      // Book available, 48-hour hold window started
    case fulfilled  // User checked out the reserved book
    case cancelled  // User cancelled the reservation
    case expired    // 48-hour hold window passed without checkout
}
