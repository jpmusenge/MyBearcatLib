//
//  Book.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/16/26.
//

// This is the core data model for a book in the library. Every book in the app is represented by this struct

import Foundation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let author: String
    let isbn: String
    let genre: String
    let coverImageName: String?   // Local image name for now; URL later
    let description: String
    
    // Physical location in the library
    let floor: Int
    let section: String
    let aisle: String
    let shelf: String
    
    // "var" not "let" because they can change
    var isAvailable: Bool
    var dueDate: Date?
    
    // MARK: - Firestore-specific fields
    // These are populated when a book comes from the scraper/Firestore.
    // They are optional so SampleData books still work without them.
    var firestoreId: String?
    var resourceId: Int?
    var barcode: String?
    var callNumber: String?
    var collectionName: String?
    var branchName: String?
    var status: String?
    var lastUpdated: String?
    var source: String?
    
    // MARK: Initializer
    // The init() function is called when you create a new Book
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        isbn: String,
        genre: String,
        coverImageName: String? = nil,
        description: String = "",
        floor: Int,
        section: String,
        aisle: String,
        shelf: String,
        isAvailable: Bool = true,
        dueDate: Date? = nil,
        firestoreId: String? = nil,
        resourceId: Int? = nil,
        barcode: String? = nil,
        callNumber: String? = nil,
        collectionName: String? = nil,
        branchName: String? = nil,
        status: String? = nil,
        lastUpdated: String? = nil,
        source: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.genre = genre
        self.coverImageName = coverImageName
        self.description = description
        self.floor = floor
        self.section = section
        self.aisle = aisle
        self.shelf = shelf
        self.isAvailable = isAvailable
        self.dueDate = dueDate
        self.firestoreId = firestoreId
        self.resourceId = resourceId
        self.barcode = barcode
        self.callNumber = callNumber
        self.collectionName = collectionName
        self.branchName = branchName
        self.status = status
        self.lastUpdated = lastUpdated
        self.source = source
    }
    
    // MARK: Computed Properties
    var locationDescription: String {
        "Floor \(floor) · Section \(section) · Aisle \(aisle) · Shelf \(shelf)"
    }
    
    /// Short location for compact displays
    var shortLocation: String {
        "Floor \(floor), \(section)-\(aisle)"
    }
    
    /// Formatted call number, falling back to section/aisle/shelf
    var displayCallNumber: String {
        if let cn = callNumber, !cn.trimmingCharacters(in: .whitespaces).isEmpty {
            return cn
        }
        return "\(section) \(aisle) \(shelf)".trimmingCharacters(in: .whitespaces)
    }
 
    /// True if the book is overdue (past its due date).
    var isOverdue: Bool {
        guard let date = dueDate else { return false }
        return date < Date()
    }
 
    /// True if the book is due within the next 3 days.
    var isDueSoon: Bool {
        guard let date = dueDate else { return false }
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return daysLeft >= 0 && daysLeft <= 3
    }
 
    /// Human-readable due date (e.g. "Mar 25, 2026").
    var formattedDueDate: String? {
        guard let date = dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
 
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
 
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }
}
