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
        dueDate: Date? = nil
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
    }
    
    // MARK: Computed Properties
    var locationDescription: String {
        "Floor \(floor) · Section \(section) · Aisle \(aisle) · Shelf \(shelf)"
    }
    
    /// Short location for compact displays
    var shortLocation: String {
        "Floor \(floor), \(section)-\(aisle)"
    }
}
