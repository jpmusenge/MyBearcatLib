//
//  Checkout.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/26/26.
//

// PURPOSE: Represents a single book checkout record for a user

import Foundation

struct Checkout: Identifiable, Hashable {
    let id: String                 // Firestore document ID
    let userId: String
    let bookFirestoreId: String    // Links back to the books collection
    let title: String
    let author: String
    let isbn: String
    let checkedOutDate: Date
    var dueDate: Date
    var renewCount: Int
    var isReturned: Bool

    // MARK: - Computed Properties

    var daysUntilDue: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: dueDate)
        ).day ?? 0
    }

    var isOverdue: Bool { daysUntilDue < 0 }
    var isDueSoon: Bool { daysUntilDue >= 0 && daysUntilDue <= 3 }

    var statusText: String {
        if daysUntilDue < 0 { return "OVERDUE \(abs(daysUntilDue)) DAYS" }
        if daysUntilDue == 0 { return "DUE TODAY" }
        if daysUntilDue == 1 { return "DUE TOMORROW" }
        return "DUE IN \(daysUntilDue) DAYS"
    }

    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }

    /// Max 2 renewals allowed
    var canRenew: Bool { renewCount < 2 && !isReturned }
}
